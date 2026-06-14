# Source-to-Ontology Mapping Table

This table explains how each planned data source should map into `ontology_v1.0.yaml`.
It is intended as a teacher-facing bridge between external biomedical databases
and the ontology-first construction strategy.

| Source | Main content | Ontology entities | Ontology relations | Key fields to preserve | Notes |
|---|---|---|---|---|---|
| DisGeNET | Gene-disease associations | `Gene`, `Disease` | `associated_with` | gene ID/symbol, disease ID/name, UMLS ID, score, association type, evidence, PMID/source | Main source for curated or semi-curated gene-disease links. Best first database for building the initial graph. |
| STRING | Protein-protein interactions | `Protein` | `interacts_with` | STRING protein ID, protein name/symbol, combined score, experimental/database/text-mining/coexpression scores, organism | `interacts_with` should be treated as symmetric/undirected in the ontology. |
| KEGG | Genes, pathways, metabolic pathways, compounds | `Gene`, `Pathway`, `Metabolite` | `participates_in`, `involved_in_pathway`, possibly `subpathway_of` | KEGG gene ID, pathway ID, compound ID, pathway name, organism, pathway category | First pathway-layer source for biological interpretation and graph enrichment. |
| HMDB | Metabolites and disease/metabolic information | `Metabolite`, `Disease`, `Pathway` | `associated_with_metabolic_change`, `involved_in_pathway` | HMDB ID, metabolite name, formula, molecular weight, disease association, concentration/sample type if available | Adds the metabolomics layer after the first pathway schema is available. Disease links may need literature review. |
| Reactome | Pathways and pathway hierarchy | `Gene`, `Protein`, `Pathway` | `participates_in`, `involved_in`, `subpathway_of` | Reactome stable ID, pathway hierarchy, participants, species, evidence/source | Extends and validates the `Pathway` layer with pathway hierarchy and participant evidence. |
| Human Protein Atlas | Protein expression in tissue/cell type | `Protein`, `Tissue`, `CellType` | `expressed_in_tissue`, `expressed_in_celltype`, `located_in` | tissue name, cell type, expression level/score, protein ID/name, source page/record | Important for liver-specific biological context. |
| PubMed | Literature evidence and new candidate relations | All ontology entities, depending on extraction result | Candidate use of `associated_with`, `associated_with_pathogenesis`, `associated_with_metabolic_change`, `involved_in_disease`, `interacts_with`, `participates_in`, `involved_in` | PMID, title, abstract/full-text passage, evidence sentence, extraction method, confidence score | LLM-extracted triples should be marked as candidate until manually or automatically validated. |
| Project-defined liver progression model | Canonical liver disease stages | `Disease` | `progresses_to` | stage name, stage order, evidence source, guideline/literature support | Defines the stage-aware backbone of the graph: Healthy liver -> NAFLD -> NASH -> Fibrosis -> Cirrhosis -> HCC. |

## Recommended Integration Order

1. `v0.1` DisGeNET: confirm `Gene`, `Disease`, `associated_with`, and the disease progression backbone.
2. `v0.2` STRING: add `Protein`, `interacts_with`, and Gene-Protein `encodes` mapping.
3. `v0.3` KEGG: add the first `Pathway` layer and pathway participation relations.
4. `v0.4` HMDB: add `Metabolite` and metabolic disease/pathway relations.
5. `v0.5` Reactome: extend the `Pathway` layer with hierarchy and participant evidence.
6. `v0.6` Human Protein Atlas: add `Tissue`, `CellType`, and expression-context relations.
7. `v0.7` PubMed + LLM: add literature-derived candidate triples under schema constraints.
8. `v1.0` Liver Disease Ontology: consolidate validated entities, relations, attributes, evidence rules, and source mappings.
9. Run graph learning/link prediction only after a stable graph version exists.

## Key Design Message

The project should not build a separate graph for each database. Instead, each
database is mapped into the same ontology. This makes the knowledge graph
consistent, easier to validate, and suitable for later LLM-based enrichment and
graph learning.
