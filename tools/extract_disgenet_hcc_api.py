#!/usr/bin/env python3
"""Extract liver disease Gene-Disease associations from the DisGeNET REST API.

This script writes normalized JSONL files aligned with the current project
ontology:

- Gene entity
- Disease entity
- Gene associated_with Disease relation

It reads the API key from DISGENET_API_KEY and never writes the key to disk.
"""

from __future__ import annotations

import argparse
import json
import os
import sys
import time
import urllib.error
import urllib.parse
import urllib.request
from datetime import datetime, timezone
from pathlib import Path
from typing import Any


ENDPOINT = "https://api.disgenet.com/api/v1/gda/summary"
DEFAULT_DISEASE_CUI = "C2239176"
DEFAULT_STAGE_NAME = "HCC"
DEFAULT_SMOKE_DISEASES = {
    "NAFLD": None,
    "NASH": None,
    "Fibrosis": None,
    "Cirrhosis": None,
    "HCC": "C2239176",
}
DEFAULT_SOURCE_VERSION = "DisGeNET API gda/summary"


def now_iso() -> str:
    return datetime.now(timezone.utc).isoformat()


def normalize_disease_param(cui: str) -> str:
    value = cui.strip()
    if value.upper().startswith("UMLS_"):
        return value.upper()
    return f"UMLS_{value.upper()}"


def request_page(api_key: str, disease_cui: str, page_number: int, source: str | None) -> dict[str, Any]:
    params = {
        "disease": normalize_disease_param(disease_cui),
        "page_number": str(page_number),
    }
    if source:
        params["source"] = source

    url = ENDPOINT + "?" + urllib.parse.urlencode(params)
    request = urllib.request.Request(
        url,
        headers={
            "Authorization": api_key,
            "accept": "application/json",
        },
    )
    try:
        with urllib.request.urlopen(request, timeout=40) as response:
            return json.loads(response.read().decode("utf-8"))
    except urllib.error.HTTPError as exc:
        body = exc.read().decode("utf-8", "replace")
        retry_after = exc.headers.get("X-Rate-Limit-Retry-After-Seconds")
        if exc.code == 429:
            message = "DisGeNET API rate limit reached"
            if retry_after:
                message += f"; retry after {retry_after} seconds"
            raise RuntimeError(message) from exc
        raise RuntimeError(f"DisGeNET API error {exc.code}: {body[:500]}") from exc


def listify(value: Any) -> list[Any]:
    if value is None or value == "":
        return []
    if isinstance(value, list):
        return value
    return [value]


def extract_external_ids(vocabularies: list[str]) -> dict[str, list[str]]:
    ids: dict[str, list[str]] = {}
    for item in vocabularies:
        text = str(item)
        if "_" in text:
            prefix, value = text.split("_", 1)
            ids.setdefault(prefix, []).append(value)
        else:
            ids.setdefault("raw", []).append(text)
    return ids


def first_non_empty(rows: list[dict[str, Any]], key: str, default: Any = None) -> Any:
    for row in rows:
        value = row.get(key)
        if value not in (None, "", [], {}):
            return value
    return default


def build_disease_entity(rows: list[dict[str, Any]], disease_cui: str, stage_name: str, created_at: str) -> dict[str, Any]:
    disease_name = first_non_empty(rows, "diseaseName", stage_name)
    vocabularies = listify(first_non_empty(rows, "diseaseVocabularies", []))
    return {
        "entity_id": f"UMLS:{disease_cui}",
        "entity_type": "Disease",
        "name": stage_name,
        "source": "DisGeNET",
        "associated_stage": stage_name,
        "identifiers": {
            "umls_cui": disease_cui,
            "original_disease_name": disease_name,
            "external_ids": extract_external_ids(vocabularies),
            "disease_vocabularies": vocabularies,
        },
        "attributes": {
            "is_progression_stage": True,
            "disease_type": first_non_empty(rows, "diseaseType"),
            "disease_classes_msh": listify(first_non_empty(rows, "diseaseClasses_MSH", [])),
            "disease_classes_umls_st": listify(first_non_empty(rows, "diseaseClasses_UMLS_ST", [])),
            "disease_classes_do": listify(first_non_empty(rows, "diseaseClasses_DO", [])),
            "disease_classes_hpo": listify(first_non_empty(rows, "diseaseClasses_HPO", [])),
            "disease_prevalence_class": first_non_empty(rows, "disease_prevalence_class"),
            "disease_prevalence_geo_area": first_non_empty(rows, "disease_prevalence_geo_area"),
            "disease_prevalence_type": first_non_empty(rows, "disease_prevalence_type"),
            "disease_inheritance": first_non_empty(rows, "disease_inheritance"),
        },
        "provenance": {
            "api_endpoint": ENDPOINT,
            "api_query": f"disease={normalize_disease_param(disease_cui)}",
            "created_at": created_at,
        },
    }


def build_gene_entity(row: dict[str, Any], created_at: str, stage_name: str) -> dict[str, Any]:
    gene_id = str(row["geneNcbiID"])
    symbol = row.get("symbolOfGene") or gene_id
    return {
        "entity_id": f"NCBIGene:{gene_id}",
        "entity_type": "Gene",
        "name": symbol,
        "source": "DisGeNET",
        "associated_stage": stage_name,
        "identifiers": {
            "ncbi_gene_id": gene_id,
            "ensembl_gene_ids": listify(row.get("geneEnsemblIDs")),
            "protein_ids_from_disgenet": listify(row.get("geneProteinStrIDs")),
        },
        "attributes": {
            "gene_ncbi_type": row.get("geneNcbiType"),
            "gene_dsi": row.get("geneDSI"),
            "gene_dpi": row.get("geneDPI"),
            "gene_pli": row.get("genepLI"),
            "gene_protein_class_ids": listify(row.get("geneProteinClassIDs")),
            "gene_protein_class_names": listify(row.get("geneProteinClassNames")),
        },
        "provenance": {
            "api_endpoint": ENDPOINT,
            "source_record_id": row.get("assocID"),
            "created_at": created_at,
        },
    }


def build_relation(row: dict[str, Any], disease_cui: str, stage_name: str, created_at: str) -> dict[str, Any]:
    gene_id = str(row["geneNcbiID"])
    symbol = row.get("symbolOfGene") or gene_id
    assoc_id = row.get("assocID") or f"{gene_id}-{disease_cui}"
    return {
        "relation_id": f"DISGENET_ASSOC:{assoc_id}",
        "relation_type": "associated_with",
        "head_entity_id": f"NCBIGene:{gene_id}",
        "head_entity_type": "Gene",
        "head_entity_name": symbol,
        "tail_entity_id": f"UMLS:{disease_cui}",
        "tail_entity_type": "Disease",
        "tail_entity_name": stage_name,
        "source": "DisGeNET",
        "source_record_id": assoc_id,
        "score": row.get("score"),
        "normalized_score": row.get("normalized_score"),
        "evidence_level": "curated_database",
        "evidence": {
            "num_pmids": row.get("numPMIDs"),
            "num_db_snp_supporting_association": row.get("numDBSNPsupportingAssociation"),
            "num_ct_supporting_association": row.get("numCTsupportingAssociation"),
            "year_initial": row.get("yearInitial"),
            "year_final": row.get("yearFinal"),
            "evidence_index": row.get("ei"),
            "disgenet_evidence_level": row.get("el"),
            "score_breakdown": row.get("scoreBreakdown"),
            "num_chemicals_in_evidence": row.get("numChemsIncludedInEvidences"),
            "num_pmids_with_chemicals": row.get("numPMIDSWithChemsIncludedInEvidences"),
            "num_trials_with_chemicals": row.get("numNCTSWithChemsIncludedInEvidences"),
            "chemicals_in_evidence": row.get("chemsIncludedInEvidenceBySource"),
        },
        "validation_status": "imported",
        "provenance": {
            "api_endpoint": ENDPOINT,
            "api_query": f"disease={normalize_disease_param(disease_cui)}",
            "created_at": created_at,
        },
    }


def write_jsonl(path: Path, rows: list[dict[str, Any]]) -> None:
    with path.open("w", encoding="utf-8") as handle:
        for row in rows:
            handle.write(json.dumps(row, ensure_ascii=False, sort_keys=True) + "\n")


def dedupe_dicts(rows: list[dict[str, Any]], key: str) -> list[dict[str, Any]]:
    seen: dict[str, dict[str, Any]] = {}
    for row in rows:
        seen[str(row[key])] = row
    return [seen[item] for item in sorted(seen)]


def top_rows(rows: list[dict[str, Any]], n: int) -> list[dict[str, Any]]:
    return sorted(
        rows,
        key=lambda row: (
            row.get("normalized_score") if isinstance(row.get("normalized_score"), (int, float)) else -1,
            row.get("score") if isinstance(row.get("score"), (int, float)) else -1,
            row.get("numPMIDs") if isinstance(row.get("numPMIDs"), (int, float)) else -1,
        ),
        reverse=True,
    )[:n]


def fetch_disease_rows(api_key: str, disease_cui: str, source: str | None, max_pages: int) -> tuple[list[dict[str, Any]], list[dict[str, Any]]]:
    rows: list[dict[str, Any]] = []
    pages: list[dict[str, Any]] = []
    for page in range(max_pages):
        data = request_page(api_key, disease_cui, page, source)
        payload = data.get("payload") or []
        pages.append(
            {
                "page_number": page,
                "rows": len(payload),
                "paging": data.get("paging"),
                "warnings": data.get("warnings"),
                "status": data.get("status"),
            }
        )
        rows.extend(payload)
        if not payload:
            break
        paging = data.get("paging") or {}
        if paging.get("currentPageNumber") != page:
            break
        if len(rows) >= int(paging.get("totalElements") or len(rows)):
            break
        time.sleep(0.5)
    return rows, pages


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--disease-cui", default=DEFAULT_DISEASE_CUI)
    parser.add_argument("--stage-name", default=DEFAULT_STAGE_NAME)
    parser.add_argument(
        "--disease",
        action="append",
        default=[],
        help="Disease smoke item in the form StageName:CUI, e.g. HCC:C2239176. Can be repeated.",
    )
    parser.add_argument("--top-n", type=int, default=10)
    parser.add_argument("--source", default=None, help="Optional DisGeNET source filter")
    parser.add_argument("--max-pages", type=int, default=1, help="Trial accounts usually allow only page 0")
    parser.add_argument(
        "--output-dir",
        type=Path,
        default=Path("data/disgenet_api_hcc"),
        help="Directory for entities.jsonl, relations.jsonl, and extraction_metadata.json",
    )
    args = parser.parse_args()

    api_key = os.getenv("DISGENET_API_KEY")
    if not api_key:
        print("DISGENET_API_KEY is not set", file=sys.stderr)
        return 2

    disease_cui = args.disease_cui.replace("UMLS_", "").upper()
    created_at = now_iso()
    disease_specs: list[tuple[str, str]] = []
    if args.disease:
        for item in args.disease:
            if ":" not in item:
                print(f"Invalid --disease value: {item}. Expected StageName:CUI", file=sys.stderr)
                return 2
            name, cui = item.split(":", 1)
            disease_specs.append((name.strip(), cui.replace("UMLS_", "").strip().upper()))
    else:
        disease_specs.append((args.stage_name, disease_cui))

    all_api_rows: list[tuple[str, str, list[dict[str, Any]]]] = []
    metadata: dict[str, Any] = {
        "endpoint": ENDPOINT,
        "disease_specs": [{"stage_name": name, "disease_cui": cui} for name, cui in disease_specs],
        "source": args.source,
        "created_at": created_at,
        "top_n": args.top_n,
        "pages": [],
    }

    for stage_name, disease_cui in disease_specs:
        try:
            rows, pages = fetch_disease_rows(api_key, disease_cui, args.source, args.max_pages)
        except RuntimeError as exc:
            print(str(exc), file=sys.stderr)
            return 3
        selected = top_rows(rows, args.top_n)
        all_api_rows.append((stage_name, disease_cui, selected))
        metadata["pages"].append({"stage_name": stage_name, "disease_cui": disease_cui, "pages": pages, "selected_rows": len(selected)})

    if not any(rows for _, _, rows in all_api_rows):
        print("No rows returned from DisGeNET API", file=sys.stderr)
        return 1

    entities: list[dict[str, Any]] = []
    relations: list[dict[str, Any]] = []
    for stage_name, disease_cui, rows in all_api_rows:
        if not rows:
            continue
        entities.append(build_disease_entity(rows, disease_cui, stage_name, created_at))
        for row in rows:
            if row.get("geneNcbiID") is None:
                continue
            entities.append(build_gene_entity(row, created_at, stage_name))
            relations.append(build_relation(row, disease_cui, stage_name, created_at))

    entities = dedupe_dicts(entities, "entity_id")
    relations = dedupe_dicts(relations, "relation_id")

    args.output_dir.mkdir(parents=True, exist_ok=True)
    write_jsonl(args.output_dir / "entities.jsonl", entities)
    write_jsonl(args.output_dir / "relations.jsonl", relations)
    (args.output_dir / "extraction_metadata.json").write_text(
        json.dumps(
            {
                **metadata,
                "entity_count": len(entities),
                "relation_count": len(relations),
                "note": "API key and full raw API payload are not stored.",
            },
            ensure_ascii=False,
            indent=2,
        ),
        encoding="utf-8",
    )

    print(f"entities: {len(entities)}")
    print(f"relations: {len(relations)}")
    print(f"output_dir: {args.output_dir}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
