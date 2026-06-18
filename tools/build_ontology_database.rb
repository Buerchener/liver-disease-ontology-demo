#!/usr/bin/env ruby
# frozen_string_literal: true

require "csv"
require "fileutils"
require "json"
require "optparse"
require "sqlite3"
require "yaml"

options = {
  yaml: File.join("ontology", "ontology_v1.0.yaml"),
  mapping: File.join("ontology", "source_mapping_table.md"),
  out: File.join("output", "ontology_database")
}

OptionParser.new do |opts|
  opts.banner = "Usage: ruby tools/build_ontology_database.rb [options]"
  opts.on("--yaml PATH", "Ontology YAML path") { |value| options[:yaml] = value }
  opts.on("--mapping PATH", "Source mapping Markdown path") { |value| options[:mapping] = value }
  opts.on("--out DIR", "Output directory") { |value| options[:out] = value }
end.parse!

def snake_case(value)
  value.to_s
       .gsub(/([a-z\d])([A-Z])/, "\\1_\\2")
       .tr("-", "_")
       .gsub(/\W+/, "_")
       .gsub(/_+/, "_")
       .gsub(/\A_+|_+\z/, "")
       .downcase
end

def sql_identifier(value)
  %("#{snake_case(value).gsub('"', '""')}")
end

def scalar(value)
  case value
  when Array, Hash
    JSON.generate(value)
  when true
    1
  when false
    0
  else
    value
  end
end

def attr_names(config)
  attributes = config.fetch("attributes", {})
  %w[confirmed recommended planned].flat_map { |group| attributes.fetch(group, []) }.uniq
end

def create_table(db, table_name, columns, primary_key: nil)
  defs = columns.map { |name, type| "#{sql_identifier(name)} #{type}" }
  defs << "PRIMARY KEY (#{Array(primary_key).map { |name| sql_identifier(name) }.join(", ")})" if primary_key
  db.execute("CREATE TABLE IF NOT EXISTS #{sql_identifier(table_name)} (#{defs.join(", ")})")
end

def insert_row(db, table_name, row)
  columns = row.keys
  placeholders = (["?"] * columns.length).join(", ")
  sql = "INSERT INTO #{sql_identifier(table_name)} (#{columns.map { |c| sql_identifier(c) }.join(", ")}) VALUES (#{placeholders})"
  db.execute(sql, columns.map { |column| scalar(row[column]) })
end

def parse_mapping_table(path)
  return [] unless File.exist?(path)

  rows = []
  File.readlines(path, chomp: true).each do |line|
    next unless line.start_with?("|")
    next if line.include?("---")

    cells = line.split("|").map(&:strip)
    cells.shift
    cells.pop
    next unless cells.length == 6
    next if cells.first == "Source"

    rows << {
      "source" => cells[0],
      "main_content" => cells[1],
      "ontology_entities" => cells[2],
      "ontology_relations" => cells[3],
      "key_fields_to_preserve" => cells[4],
      "notes" => cells[5]
    }
  end
  rows
end

def export_csvs(db, out_dir)
  csv_dir = File.join(out_dir, "csv")
  FileUtils.mkdir_p(csv_dir)
  table_names = db.execute("SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%' ORDER BY name").flatten

  table_names.each do |table|
    rows = db.execute2("SELECT * FROM #{sql_identifier(table)}")
    headers = rows.shift || []
    CSV.open(File.join(csv_dir, "#{table}.csv"), "w") do |csv|
      csv << headers
      rows.each { |row| csv << row }
    end
  end
end

ontology = YAML.load_file(options[:yaml])
out_dir = options[:out]
FileUtils.mkdir_p(out_dir)

db_path = File.join(out_dir, "liver_disease_ontology.db")
schema_path = File.join(out_dir, "schema.sql")
FileUtils.rm_f(db_path)

db = SQLite3::Database.new(db_path)
db.results_as_hash = false

db.transaction do
  create_table(db, "ontology_metadata", {
    "key" => "TEXT NOT NULL",
    "value" => "TEXT"
  }, primary_key: "key")

  ontology.fetch("ontology", {}).each do |key, value|
    next if %w[scope design_principles].include?(key)

    insert_row(db, "ontology_metadata", "key" => key, "value" => value)
  end

  create_table(db, "ontology_use_cases", {
    "position" => "INTEGER NOT NULL",
    "use_case" => "TEXT NOT NULL"
  }, primary_key: "position")
  ontology.dig("ontology", "scope", "primary_use_cases").to_a.each_with_index do |use_case, index|
    insert_row(db, "ontology_use_cases", "position" => index + 1, "use_case" => use_case)
  end

  create_table(db, "ontology_design_principles", {
    "position" => "INTEGER NOT NULL",
    "principle" => "TEXT NOT NULL"
  }, primary_key: "position")
  ontology.dig("ontology", "design_principles").to_a.each_with_index do |principle, index|
    insert_row(db, "ontology_design_principles", "position" => index + 1, "principle" => principle)
  end

  create_table(db, "identifier_policy_fields", {
    "position" => "INTEGER NOT NULL",
    "field_name" => "TEXT NOT NULL"
  }, primary_key: "position")
  ontology.dig("identifier_policy", "recommended_fields").to_a.each_with_index do |field, index|
    insert_row(db, "identifier_policy_fields", "position" => index + 1, "field_name" => field)
  end

  create_table(db, "identifier_policy_notes", {
    "position" => "INTEGER NOT NULL",
    "note" => "TEXT NOT NULL"
  }, primary_key: "position")
  ontology.dig("identifier_policy", "notes").to_a.each_with_index do |note, index|
    insert_row(db, "identifier_policy_notes", "position" => index + 1, "note" => note)
  end

  create_table(db, "disease_stages", {
    "stage_id" => "TEXT NOT NULL",
    "name" => "TEXT NOT NULL",
    "stage_order" => "INTEGER",
    "disease_name" => "TEXT",
    "is_progression_stage" => "INTEGER"
  }, primary_key: "stage_id")
  ontology.dig("disease_progression_model", "canonical_stages").to_a.each do |stage|
    insert_row(db, "disease_stages", {
      "stage_id" => stage["stage_id"],
      "name" => stage["name"],
      "stage_order" => stage["order"],
      "disease_name" => stage["disease_name"],
      "is_progression_stage" => stage["is_progression_stage"]
    })
  end

  create_table(db, "canonical_progression_edges", {
    "source" => "TEXT NOT NULL",
    "target" => "TEXT NOT NULL",
    "relation" => "TEXT NOT NULL"
  })
  ontology.dig("disease_progression_model", "canonical_progression_edges").to_a.each do |edge|
    insert_row(db, "canonical_progression_edges", edge)
  end

  create_table(db, "evidence_levels", {
    "evidence_level" => "TEXT NOT NULL",
    "description" => "TEXT NOT NULL"
  }, primary_key: "evidence_level")
  ontology.dig("evidence_policy", "evidence_levels").to_h.each do |level, description|
    insert_row(db, "evidence_levels", "evidence_level" => level, "description" => description)
  end

  create_table(db, "relation_provenance_fields", {
    "field_group" => "TEXT NOT NULL",
    "position" => "INTEGER NOT NULL",
    "field_name" => "TEXT NOT NULL"
  }, primary_key: %w[field_group position])
  {
    "required" => ontology.dig("evidence_policy", "required_relation_provenance").to_a,
    "recommended" => ontology.dig("evidence_policy", "recommended_relation_provenance").to_a
  }.each do |group, fields|
    fields.each_with_index do |field, index|
      insert_row(db, "relation_provenance_fields", "field_group" => group, "position" => index + 1, "field_name" => field)
    end
  end

  create_table(db, "validation_status_values", {
    "position" => "INTEGER NOT NULL",
    "status_value" => "TEXT NOT NULL"
  }, primary_key: "position")
  ontology.dig("evidence_policy", "validation_status_values").to_a.each_with_index do |status, index|
    insert_row(db, "validation_status_values", "position" => index + 1, "status_value" => status)
  end

  create_table(db, "ontology_entities", {
    "entity_type" => "TEXT NOT NULL",
    "description" => "TEXT"
  }, primary_key: "entity_type")
  create_table(db, "entity_primary_id_candidates", {
    "entity_type" => "TEXT NOT NULL",
    "position" => "INTEGER NOT NULL",
    "candidate" => "TEXT NOT NULL"
  }, primary_key: %w[entity_type position])
  create_table(db, "entity_attributes", {
    "entity_type" => "TEXT NOT NULL",
    "attribute_group" => "TEXT NOT NULL",
    "position" => "INTEGER NOT NULL",
    "attribute_name" => "TEXT NOT NULL"
  }, primary_key: %w[entity_type attribute_group position])

  ontology.fetch("entities", {}).each do |entity_type, config|
    insert_row(db, "ontology_entities", "entity_type" => entity_type, "description" => config["description"])
    config.fetch("primary_id_candidates", []).each_with_index do |candidate, index|
      insert_row(db, "entity_primary_id_candidates", "entity_type" => entity_type, "position" => index + 1, "candidate" => candidate)
    end
    config.fetch("attributes", {}).each do |group, attributes|
      attributes.each_with_index do |attribute, index|
        insert_row(db, "entity_attributes", {
          "entity_type" => entity_type,
          "attribute_group" => group,
          "position" => index + 1,
          "attribute_name" => attribute
        })
      end
    end

    columns = { "id" => "INTEGER PRIMARY KEY AUTOINCREMENT" }
    attr_names(config).each { |attribute| columns[attribute] = "TEXT" }
    columns["created_at"] = "TEXT"
    columns["updated_at"] = "TEXT"
    create_table(db, "#{snake_case(entity_type)}s", columns)
  end

  create_table(db, "ontology_relations", {
    "relation_type" => "TEXT NOT NULL",
    "source_entity_type" => "TEXT NOT NULL",
    "target_entity_type" => "TEXT NOT NULL",
    "direction" => "TEXT",
    "symmetric" => "INTEGER",
    "description" => "TEXT"
  }, primary_key: "relation_type")
  create_table(db, "relation_allowed_sources", {
    "relation_type" => "TEXT NOT NULL",
    "position" => "INTEGER NOT NULL",
    "allowed_source" => "TEXT NOT NULL"
  }, primary_key: %w[relation_type position])
  create_table(db, "relation_attributes", {
    "relation_type" => "TEXT NOT NULL",
    "attribute_group" => "TEXT NOT NULL",
    "position" => "INTEGER NOT NULL",
    "attribute_name" => "TEXT NOT NULL"
  }, primary_key: %w[relation_type attribute_group position])

  ontology.fetch("relations", {}).each do |relation_type, config|
    insert_row(db, "ontology_relations", {
      "relation_type" => relation_type,
      "source_entity_type" => config["source"],
      "target_entity_type" => config["target"],
      "direction" => config["direction"],
      "symmetric" => config["symmetric"],
      "description" => config["description"]
    })
    config.fetch("allowed_sources", []).each_with_index do |source, index|
      insert_row(db, "relation_allowed_sources", "relation_type" => relation_type, "position" => index + 1, "allowed_source" => source)
    end
    config.fetch("attributes", {}).each do |group, attributes|
      attributes.each_with_index do |attribute, index|
        insert_row(db, "relation_attributes", {
          "relation_type" => relation_type,
          "attribute_group" => group,
          "position" => index + 1,
          "attribute_name" => attribute
        })
      end
    end

    source_col = "#{snake_case(config["source"])}_id"
    target_col = "#{snake_case(config["target"])}_id"
    target_col = "#{target_col}_2" if source_col == target_col
    relation_columns = {
      "id" => "INTEGER PRIMARY KEY AUTOINCREMENT",
      source_col => "TEXT NOT NULL",
      target_col => "TEXT NOT NULL"
    }
    attr_names(config).each { |attribute| relation_columns[attribute] = "TEXT" }
    relation_columns["created_at"] = "TEXT"
    relation_columns["updated_at"] = "TEXT"
    create_table(db, "#{snake_case(relation_type)}_relations", relation_columns)
  end

  disease_config = ontology.dig("entities", "Disease")
  ontology.dig("disease_progression_model", "canonical_stages").to_a.each do |stage|
    row = {
      "disease_id" => stage["stage_id"],
      "disease_name" => stage["disease_name"],
      "project_id" => stage["stage_id"],
      "synonyms" => stage["name"],
      "is_progression_stage" => stage["is_progression_stage"],
      "stage_order" => stage["order"]
    }
    insert_row(db, "diseases", row.select { |key, _| attr_names(disease_config).include?(key) })
  end

  ontology.dig("disease_progression_model", "canonical_progression_edges").to_a.each do |edge|
    source = db.get_first_value("SELECT disease_id FROM diseases WHERE synonyms = ? OR disease_name = ?", edge["source"], edge["source"])
    target = db.get_first_value("SELECT disease_id FROM diseases WHERE synonyms = ? OR disease_name = ?", edge["target"], edge["target"])
    insert_row(db, "progresses_to_relations", {
      "disease_id" => source,
      "disease_id_2" => target,
      "relationship_type" => edge["relation"],
      "evidence_level" => "curated_database",
      "source" => "project-defined progression model",
      "validation_status" => "accepted"
    })
  end

  create_table(db, "llm_extracted_triple_fields", {
    "position" => "INTEGER NOT NULL",
    "field_name" => "TEXT NOT NULL"
  }, primary_key: "position")
  ontology.dig("llm_extraction_policy", "extracted_triple_fields").to_a.each_with_index do |field, index|
    insert_row(db, "llm_extracted_triple_fields", "position" => index + 1, "field_name" => field)
  end

  create_table(db, "llm_allowed_relation_targets", {
    "position" => "INTEGER NOT NULL",
    "relation_type" => "TEXT NOT NULL"
  }, primary_key: "position")
  ontology.dig("llm_extraction_policy", "allowed_relation_targets").to_a.each_with_index do |relation, index|
    insert_row(db, "llm_allowed_relation_targets", "position" => index + 1, "relation_type" => relation)
  end

  create_table(db, "graph_candidate_prediction_fields", {
    "position" => "INTEGER NOT NULL",
    "field_name" => "TEXT NOT NULL"
  }, primary_key: "position")
  ontology.dig("graph_learning_policy", "candidate_prediction_fields").to_a.each_with_index do |field, index|
    insert_row(db, "graph_candidate_prediction_fields", "position" => index + 1, "field_name" => field)
  end

  create_table(db, "graph_allowed_prediction_tasks", {
    "position" => "INTEGER NOT NULL",
    "task_name" => "TEXT NOT NULL"
  }, primary_key: "position")
  ontology.dig("graph_learning_policy", "allowed_prediction_tasks").to_a.each_with_index do |task, index|
    insert_row(db, "graph_allowed_prediction_tasks", "position" => index + 1, "task_name" => task)
  end

  create_table(db, "source_mappings", {
    "source" => "TEXT NOT NULL",
    "main_content" => "TEXT",
    "ontology_entities" => "TEXT",
    "ontology_relations" => "TEXT",
    "key_fields_to_preserve" => "TEXT",
    "notes" => "TEXT"
  }, primary_key: "source")
  parse_mapping_table(options[:mapping]).each { |row| insert_row(db, "source_mappings", row) }
end

db.execute("VACUUM")
File.write(schema_path, db.execute("SELECT sql FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%' ORDER BY name").flatten.compact.join(";\n\n") + ";\n")
export_csvs(db, out_dir)

table_count = db.get_first_value("SELECT COUNT(*) FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'")
db.close

puts "Created #{db_path}"
puts "Created #{schema_path}"
puts "Exported CSV tables to #{File.join(out_dir, "csv")}"
puts "Table count: #{table_count}"
