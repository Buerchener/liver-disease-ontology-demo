#!/usr/bin/env ruby
# frozen_string_literal: true

require "fileutils"
require "sqlite3"

options = {
  sqlite: File.join("output", "ontology_database", "liver_disease_ontology.db"),
  out: File.join("output", "ontology_database", "postgresql"),
  database: "fyp_ontology",
  schema: "ontology"
}

def quote_ident(value)
  %("#{value.to_s.gsub('"', '""')}")
end

def quote_literal(value)
  return "NULL" if value.nil?
  return value.to_s if value.is_a?(Integer) || value.is_a?(Float)

  "'#{value.to_s.gsub("'", "''")}'"
end

def translate_schema(sql)
  sql
    .gsub(/"id" INTEGER PRIMARY KEY AUTOINCREMENT/, '"id" BIGSERIAL PRIMARY KEY')
    .gsub(/\bINTEGER\b/, "INTEGER")
    .gsub(/\bTEXT\b/, "TEXT")
end

db = SQLite3::Database.new(options[:sqlite])
db.results_as_hash = false

out_dir = options[:out]
FileUtils.mkdir_p(out_dir)

create_database_sql = <<~SQL
  -- Run this first while connected to the default postgres database.
  CREATE DATABASE #{quote_ident(options[:database])};
SQL

tables = db.execute("SELECT name, sql FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%' ORDER BY name")

schema_lines = []
schema_lines << "-- Run this after connecting to database #{options[:database]}."
schema_lines << "CREATE SCHEMA IF NOT EXISTS #{quote_ident(options[:schema])};"
schema_lines << "SET search_path TO #{quote_ident(options[:schema])};"
schema_lines << ""
schema_lines << tables.reverse.map { |name, _| "DROP TABLE IF EXISTS #{quote_ident(name)} CASCADE;" }
schema_lines << ""

tables.each do |_, sql|
  schema_lines << "#{translate_schema(sql)};"
  schema_lines << ""
end

tables.each do |name, _|
  rows = db.execute2("SELECT * FROM #{quote_ident(name)}")
  headers = rows.shift
  next if rows.empty?

  columns = headers.map { |header| quote_ident(header) }.join(", ")
  rows.each do |row|
    values = row.map { |value| quote_literal(value) }.join(", ")
    schema_lines << "INSERT INTO #{quote_ident(name)} (#{columns}) VALUES (#{values});"
  end
  schema_lines << ""
end

File.write(File.join(out_dir, "01_create_database.sql"), create_database_sql)
File.write(File.join(out_dir, "02_schema_and_seed.sql"), schema_lines.flatten.join("\n"))

puts "Created #{File.join(out_dir, "01_create_database.sql")}"
puts "Created #{File.join(out_dir, "02_schema_and_seed.sql")}"
puts "Database name: #{options[:database]}"
puts "Schema name: #{options[:schema]}"
