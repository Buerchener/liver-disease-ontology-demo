#!/usr/bin/env python3
import argparse
import json
from collections import Counter, defaultdict
from pathlib import Path

import yaml


REQUIRED_ENTITY_FIELDS = {
    "project_id",
    "entity_type",
    "name",
    "primary_external_id",
    "source",
    "external_ids",
    "source_record_id",
    "attributes",
}

REQUIRED_RELATION_FIELDS = {
    "subject_id",
    "subject_type",
    "predicate",
    "object_id",
    "object_type",
    "source",
    "evidence_level",
    "evidence_text",
    "confidence_score",
    "validation_status",
    "source_record_id",
    "attributes",
}

REQUIRED_LITERATURE_FIELDS = {
    "pmid",
    "title",
    "abstract",
    "source",
    "source_record_id",
    "screening_status",
    "publication_year",
    "raw_context",
}

SOURCE_ALIASES = {
    "KEGG": {"KEGG"},
    "PubMed": {"PubMed"},
    "DisGeNET": {"DisGeNET"},
    "STRING": {"STRING"},
    "Human Protein Atlas": {"Human Protein Atlas", "HPA"},
    "HPA": {"Human Protein Atlas", "HPA"},
    "LLM extraction": {"LLM extraction", "PubMed/LLM"},
    "graph learning prediction": {"graph learning prediction"},
    "project-defined progression model": {"project-defined progression model", "ontology"},
}


def read_jsonl(path):
    rows = []
    errors = []
    if not path.exists():
        return rows, [(str(path), 0, "file does not exist")]
    for line_number, line in enumerate(path.read_text(encoding="utf-8").splitlines(), start=1):
        if not line.strip():
            continue
        try:
            rows.append(json.loads(line))
        except json.JSONDecodeError as exc:
            errors.append((str(path), line_number, str(exc)))
    return rows, errors


def load_schema(path):
    with path.open("r", encoding="utf-8") as handle:
        return yaml.safe_load(handle)


def source_matches(actual, allowed_sources):
    allowed = set()
    for source in allowed_sources or []:
        allowed.update(SOURCE_ALIASES.get(source, {source}))
    return actual in allowed


def missing_fields(row, required):
    return sorted(field for field in required if field not in row or row[field] in (None, ""))


def counter_table(counter):
    if not counter:
        return "- none\n"
    return "\n".join(f"- `{key}`: {value}" for key, value in counter.most_common()) + "\n"


def main():
    parser = argparse.ArgumentParser(description="Validate extracted JSONL data against ontology_v1.0.yaml.")
    parser.add_argument("data_dir", type=Path, help="Folder containing entities.jsonl, relations.jsonl, and literature_records.jsonl.")
    parser.add_argument("--schema", type=Path, default=Path("ontology/ontology_v1.0.yaml"))
    parser.add_argument("--output", type=Path, default=Path("reports/extracted_data_validation.md"))
    args = parser.parse_args()

    schema = load_schema(args.schema)
    entity_schema = schema.get("entities", {})
    relation_schema = schema.get("relations", {})

    entities, entity_parse_errors = read_jsonl(args.data_dir / "entities.jsonl")
    relations, relation_parse_errors = read_jsonl(args.data_dir / "relations.jsonl")
    gene_pathway, gene_pathway_parse_errors = read_jsonl(args.data_dir / "gene_pathway.jsonl")
    literature, literature_parse_errors = read_jsonl(args.data_dir / "literature_records.jsonl")

    parse_errors = entity_parse_errors + relation_parse_errors + gene_pathway_parse_errors + literature_parse_errors
    entity_ids = {row.get("project_id") for row in entities}

    issues = []
    warnings = []

    for index, row in enumerate(entities, start=1):
        missing = missing_fields(row, REQUIRED_ENTITY_FIELDS)
        if missing:
            issues.append(f"entities.jsonl line {index}: missing fields {missing}")
        entity_type = row.get("entity_type")
        if entity_type not in entity_schema:
            issues.append(f"entities.jsonl line {index}: unknown entity_type `{entity_type}`")
        if row.get("source") == "KEGG" and entity_type == "Disease":
            warnings.append(f"entities.jsonl line {index}: KEGG disease-like record is typed as Disease; check whether it should be Pathway or Disease.")

    duplicate_entities = [project_id for project_id, count in Counter(row.get("project_id") for row in entities).items() if count > 1]
    for project_id in duplicate_entities:
        issues.append(f"entities.jsonl: duplicate project_id `{project_id}`")

    for index, row in enumerate(relations, start=1):
        missing = missing_fields(row, REQUIRED_RELATION_FIELDS)
        if missing:
            issues.append(f"relations.jsonl line {index}: missing fields {missing}")

        predicate = row.get("predicate")
        rule = relation_schema.get(predicate)
        if not rule:
            issues.append(f"relations.jsonl line {index}: unknown predicate `{predicate}`")
            continue

        if row.get("subject_type") != rule.get("source"):
            issues.append(
                f"relations.jsonl line {index}: subject_type `{row.get('subject_type')}` does not match YAML source `{rule.get('source')}` for `{predicate}`"
            )
        if row.get("object_type") != rule.get("target"):
            issues.append(
                f"relations.jsonl line {index}: object_type `{row.get('object_type')}` does not match YAML target `{rule.get('target')}` for `{predicate}`"
            )
        if not source_matches(row.get("source"), rule.get("allowed_sources")):
            issues.append(
                f"relations.jsonl line {index}: source `{row.get('source')}` is not allowed for `{predicate}` by YAML"
            )
        if row.get("subject_id") not in entity_ids:
            issues.append(f"relations.jsonl line {index}: subject_id `{row.get('subject_id')}` not found in entities.jsonl")
        if row.get("object_id") not in entity_ids:
            issues.append(f"relations.jsonl line {index}: object_id `{row.get('object_id')}` not found in entities.jsonl")

    duplicate_relations = [
        key
        for key, count in Counter(
            (row.get("subject_id"), row.get("predicate"), row.get("object_id"), row.get("source_record_id"))
            for row in relations
        ).items()
        if count > 1
    ]
    for subject_id, predicate, object_id, source_record_id in duplicate_relations:
        issues.append(f"relations.jsonl: duplicate relation `{subject_id}` `{predicate}` `{object_id}` from `{source_record_id}`")

    for index, row in enumerate(literature, start=1):
        missing = missing_fields(row, REQUIRED_LITERATURE_FIELDS)
        if missing:
            issues.append(f"literature_records.jsonl line {index}: missing fields {missing}")
        if row.get("source") != "PubMed":
            issues.append(f"literature_records.jsonl line {index}: source should be `PubMed`, got `{row.get('source')}`")
        if row.get("screening_status") == "pending":
            warnings.append(f"literature_records.jsonl line {index}: PubMed record is pending and has not been converted into candidate triples.")

    relation_source_records = {row.get("source_record_id") for row in relations}
    gene_pathway_source_records = {row.get("source_record_id") for row in gene_pathway}
    missing_relation_records = sorted(gene_pathway_source_records - relation_source_records)
    if missing_relation_records:
        issues.append(f"{len(missing_relation_records)} gene_pathway records are not represented in relations.jsonl")

    entity_type_counts = Counter(row.get("entity_type") for row in entities)
    relation_counts = Counter(row.get("predicate") for row in relations)
    relation_type_counts = Counter(f"{row.get('subject_type')} -> {row.get('object_type')}" for row in relations)
    source_counts = Counter(row.get("source") for row in relations)
    literature_status_counts = Counter(row.get("screening_status") for row in literature)

    report = []
    report.append("# Extracted Data Validation Report\n")
    report.append(f"Data folder: `{args.data_dir}`\n")
    report.append(f"Schema: `{args.schema}`\n")
    report.append("\n## Summary\n")
    report.append(f"- Entities: {len(entities)}\n")
    report.append(f"- Relations: {len(relations)}\n")
    report.append(f"- Gene-pathway source rows: {len(gene_pathway)}\n")
    report.append(f"- PubMed literature records: {len(literature)}\n")
    report.append(f"- Parse errors: {len(parse_errors)}\n")
    report.append(f"- Blocking issues: {len(issues)}\n")
    report.append(f"- Warnings: {len(warnings)}\n")

    report.append("\n## Entity Types\n")
    report.append(counter_table(entity_type_counts))
    report.append("\n## Relation Predicates\n")
    report.append(counter_table(relation_counts))
    report.append("\n## Relation Type Pairs\n")
    report.append(counter_table(relation_type_counts))
    report.append("\n## Relation Sources\n")
    report.append(counter_table(source_counts))
    report.append("\n## PubMed Screening Status\n")
    report.append(counter_table(literature_status_counts))

    report.append("\n## Blocking Issues\n")
    if issues:
        report.extend(f"- {issue}\n" for issue in issues)
    else:
        report.append("- none\n")

    report.append("\n## Warnings / Next Review Items\n")
    if warnings:
        for warning in warnings[:20]:
            report.append(f"- {warning}\n")
        if len(warnings) > 20:
            report.append(f"- ... {len(warnings) - 20} more warning(s)\n")
    else:
        report.append("- none\n")

    report.append("\n## Interpretation\n")
    if not issues:
        report.append("- The KEGG entity and relation rows are structurally valid against the current YAML schema.\n")
    report.append("- Current relations cover `Gene -> participates_in -> Pathway` only.\n")
    report.append("- PubMed records are source documents only; they should not be treated as ontology relations until candidate triples are extracted and validated.\n")
    report.append("- Before database import, map generic JSONL fields to entity-specific YAML attributes, for example `primary_external_id -> gene_id/pathway_id` and `name -> gene_symbol/pathway_name` where appropriate.\n")

    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text("".join(report), encoding="utf-8")
    print(f"Wrote {args.output}")
    print(f"Blocking issues: {len(issues)}")
    print(f"Warnings: {len(warnings)}")


if __name__ == "__main__":
    main()
