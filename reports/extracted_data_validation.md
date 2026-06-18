# Extracted Data Validation Report
Data folder: `/Users/buerchener/Desktop/提取数据(少量)`
Schema: `ontology/ontology_v1.0.yaml`

## Summary
- Entities: 67
- Relations: 64
- Gene-pathway source rows: 64
- PubMed literature records: 32
- Parse errors: 0
- Blocking issues: 0
- Warnings: 32

## Entity Types
- `Gene`: 59
- `Pathway`: 8

## Relation Predicates
- `participates_in`: 64

## Relation Type Pairs
- `Gene -> Pathway`: 64

## Relation Sources
- `KEGG`: 64

## PubMed Screening Status
- `pending`: 32

## Blocking Issues
- none

## Warnings / Next Review Items
- literature_records.jsonl line 1: PubMed record is pending and has not been converted into candidate triples.
- literature_records.jsonl line 2: PubMed record is pending and has not been converted into candidate triples.
- literature_records.jsonl line 3: PubMed record is pending and has not been converted into candidate triples.
- literature_records.jsonl line 4: PubMed record is pending and has not been converted into candidate triples.
- literature_records.jsonl line 5: PubMed record is pending and has not been converted into candidate triples.
- literature_records.jsonl line 6: PubMed record is pending and has not been converted into candidate triples.
- literature_records.jsonl line 7: PubMed record is pending and has not been converted into candidate triples.
- literature_records.jsonl line 8: PubMed record is pending and has not been converted into candidate triples.
- literature_records.jsonl line 9: PubMed record is pending and has not been converted into candidate triples.
- literature_records.jsonl line 10: PubMed record is pending and has not been converted into candidate triples.
- literature_records.jsonl line 11: PubMed record is pending and has not been converted into candidate triples.
- literature_records.jsonl line 12: PubMed record is pending and has not been converted into candidate triples.
- literature_records.jsonl line 13: PubMed record is pending and has not been converted into candidate triples.
- literature_records.jsonl line 14: PubMed record is pending and has not been converted into candidate triples.
- literature_records.jsonl line 15: PubMed record is pending and has not been converted into candidate triples.
- literature_records.jsonl line 16: PubMed record is pending and has not been converted into candidate triples.
- literature_records.jsonl line 17: PubMed record is pending and has not been converted into candidate triples.
- literature_records.jsonl line 18: PubMed record is pending and has not been converted into candidate triples.
- literature_records.jsonl line 19: PubMed record is pending and has not been converted into candidate triples.
- literature_records.jsonl line 20: PubMed record is pending and has not been converted into candidate triples.
- ... 12 more warning(s)

## Interpretation
- The KEGG entity and relation rows are structurally valid against the current YAML schema.
- Current relations cover `Gene -> participates_in -> Pathway` only.
- PubMed records are source documents only; they should not be treated as ontology relations until candidate triples are extracted and validated.
- Before database import, map generic JSONL fields to entity-specific YAML attributes, for example `primary_external_id -> gene_id/pathway_id` and `name -> gene_symbol/pathway_name` where appropriate.
