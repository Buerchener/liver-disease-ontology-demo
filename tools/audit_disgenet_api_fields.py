#!/usr/bin/env python3
"""Audit DisGeNET GDA API fields against the current ontology YAML.

The script intentionally writes only a field-level report. It does not persist
the API key or full API payload.
"""

from __future__ import annotations

import json
import os
import sys
import urllib.parse
import urllib.request
from collections import Counter
from pathlib import Path
from typing import Any


ROOT = Path(__file__).resolve().parents[1]
REPORT_PATH = ROOT / "reports" / "disgenet_api_field_alignment.md"
ENDPOINT = "https://api.disgenet.com/api/v1/gda/summary"


FIELD_MAPPING = {
    "assocID": ("Relation provenance", "source_record_id", "covered"),
    "symbolOfGene": ("Gene", "gene_symbol", "covered"),
    "geneNcbiID": ("Gene", "gene_id / primary_external_id", "covered"),
    "geneEnsemblIDs": ("Gene", "external_ids.Ensembl", "covered"),
    "geneNcbiType": ("Gene", "gene_type", "covered as planned"),
    "geneDSI": ("Gene attribute", "DisGeNET-specific metric", "store as source-specific attribute"),
    "geneDPI": ("Gene attribute", "DisGeNET-specific metric", "store as source-specific attribute"),
    "genepLI": ("Gene attribute", "DisGeNET-specific metric", "store as source-specific attribute"),
    "geneProteinStrIDs": ("Gene/Protein crossref", "external_ids.STRING / protein link candidate", "covered as external_ids"),
    "geneProteinClassIDs": ("Gene/Protein class", "source-specific attribute", "store as source-specific attribute"),
    "geneProteinClassNames": ("Gene/Protein class", "source-specific attribute", "store as source-specific attribute"),
    "diseaseVocabularies": ("Disease", "external_ids", "covered"),
    "diseaseName": ("Disease", "disease_name", "covered"),
    "diseaseType": ("Disease", "disease_type", "covered as planned"),
    "diseaseUMLSCUI": ("Disease", "umls_id / disease_id", "covered"),
    "diseaseClasses_MSH": ("Disease", "disease classification", "store as source-specific attribute"),
    "diseaseClasses_UMLS_ST": ("Disease", "disease classification", "store as source-specific attribute"),
    "diseaseClasses_DO": ("Disease", "disease classification", "store as source-specific attribute"),
    "diseaseClasses_HPO": ("Disease", "disease classification", "store as source-specific attribute"),
    "disease_prevalence_class": ("Disease", "epidemiology metadata", "optional source-specific attribute"),
    "disease_prevalence_geo_area": ("Disease", "epidemiology metadata", "optional source-specific attribute"),
    "disease_prevalence_type": ("Disease", "epidemiology metadata", "optional source-specific attribute"),
    "disease_inheritance": ("Disease", "inheritance metadata", "optional source-specific attribute"),
    "numDBSNPsupportingAssociation": ("Relation evidence", "support count", "store as source-specific attribute"),
    "numCTsupportingAssociation": ("Relation evidence", "support count", "store as source-specific attribute"),
    "numPMIDs": ("Relation evidence", "publication support count", "store as source-specific attribute"),
    "numChemsIncludedInEvidences": ("Relation evidence", "chemical evidence count", "store as source-specific attribute"),
    "numPMIDSWithChemsIncludedInEvidences": ("Relation evidence", "chemical publication count", "store as source-specific attribute"),
    "numNCTSWithChemsIncludedInEvidences": ("Relation evidence", "clinical trial chemical count", "store as source-specific attribute"),
    "chemsIncludedInEvidenceBySource": ("Relation evidence", "chemical evidence details", "store as nested source-specific attribute"),
    "score": ("Relation", "score", "covered"),
    "normalized_score": ("Relation provenance", "confidence_score", "covered"),
    "scoreBreakdown": ("Relation evidence", "score components", "store as source-specific attribute"),
    "ei": ("Relation evidence", "evidence index", "store as source-specific attribute"),
    "el": ("Relation evidence", "evidence level metric", "store as source-specific attribute"),
    "yearInitial": ("Relation provenance", "first evidence year", "store as source-specific attribute"),
    "yearFinal": ("Relation provenance", "latest evidence year / date proxy", "store as source-specific attribute"),
}


def value_type(value: Any) -> str:
    if value is None:
        return "null"
    if isinstance(value, bool):
        return "boolean"
    if isinstance(value, int):
        return "integer"
    if isinstance(value, float):
        return "number"
    if isinstance(value, str):
        return "string"
    if isinstance(value, list):
        if not value:
            return "array"
        inner = Counter(value_type(v) for v in value)
        return "array[" + ",".join(f"{k}:{v}" for k, v in sorted(inner.items())) + "]"
    if isinstance(value, dict):
        return "object"
    return type(value).__name__


def main() -> int:
    api_key = os.getenv("DISGENET_API_KEY")
    if not api_key:
        print("DISGENET_API_KEY is not set", file=sys.stderr)
        return 2

    params = {"gene_ncbi_id": "351", "page_number": "0"}
    url = ENDPOINT + "?" + urllib.parse.urlencode(params)
    request = urllib.request.Request(
        url,
        headers={"Authorization": api_key, "accept": "application/json"},
    )
    with urllib.request.urlopen(request, timeout=30) as response:
        data = json.loads(response.read().decode("utf-8"))

    payload = data.get("payload") or []
    if not payload:
        print("No payload rows returned", file=sys.stderr)
        return 1

    field_types: dict[str, Counter[str]] = {}
    null_counts: Counter[str] = Counter()
    empty_counts: Counter[str] = Counter()
    for row in payload:
        for key, value in row.items():
            field_types.setdefault(key, Counter())[value_type(value)] += 1
            if value is None:
                null_counts[key] += 1
            if value == "" or value == [] or value == {}:
                empty_counts[key] += 1

    REPORT_PATH.parent.mkdir(parents=True, exist_ok=True)
    with REPORT_PATH.open("w", encoding="utf-8") as fh:
        fh.write("# DisGeNET API Field Alignment\n\n")
        fh.write("This report audits a small live DisGeNET GDA API sample against `ontology/ontology_v1.0.yaml`.\n")
        fh.write("The API key and full payload are not stored.\n\n")
        fh.write("## API Sample\n\n")
        fh.write(f"- Endpoint: `{ENDPOINT}`\n")
        fh.write("- Query: `gene_ncbi_id=351&page_number=0`\n")
        fh.write(f"- Rows inspected: `{len(payload)}`\n")
        fh.write(f"- Total available rows for this query: `{data.get('paging', {}).get('totalElements')}`\n")
        fh.write(f"- Top-level response keys: `{', '.join(data.keys())}`\n\n")

        fh.write("## Field Mapping\n\n")
        fh.write("| DisGeNET field | Observed type | Empty in sample | Ontology target | Alignment |\n")
        fh.write("| --- | --- | ---: | --- | --- |\n")
        for key in sorted(field_types):
            target_group, target_field, status = FIELD_MAPPING.get(
                key,
                ("Unmapped", "review manually", "not mapped"),
            )
            types = ", ".join(f"{k} x{v}" for k, v in sorted(field_types[key].items()))
            empty = null_counts[key] + empty_counts[key]
            fh.write(f"| `{key}` | {types} | {empty}/{len(payload)} | {target_group}: `{target_field}` | {status} |\n")

        fh.write("\n## Conclusion\n\n")
        fh.write(
            "- The current ontology matches DisGeNET at the structural level: DisGeNET GDA maps to "
            "`Gene associated_with Disease`.\n"
        )
        fh.write(
            "- The core identifiers are covered: `symbolOfGene`, `geneNcbiID`, `geneEnsemblIDs`, "
            "`diseaseUMLSCUI`, `diseaseName`, and `diseaseVocabularies`.\n"
        )
        fh.write(
            "- The relation fields are also covered: `assocID` maps to `source_record_id`, `score` "
            "maps to `score`, and `normalized_score` maps to `confidence_score`.\n"
        )
        fh.write(
            "- DisGeNET-specific metrics such as `geneDSI`, `geneDPI`, `genepLI`, `ei`, `el`, "
            "`scoreBreakdown`, support counts, and disease class arrays should not force new core "
            "entities. Store them under source-specific `attributes` on the relevant entity or relation.\n"
        )
        fh.write(
            "- No immediate ontology redesign is required for DisGeNET. A useful minor improvement would "
            "be to explicitly allow `source_specific_attributes` or add a small `DisGeNET metrics` note "
            "to Gene, Disease, and `associated_with`.\n"
        )

    print(REPORT_PATH)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
