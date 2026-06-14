# Teacher-Facing Explanation

## Short Version

The project direction can be adjusted from a database-first knowledge graph to
an ontology-first knowledge graph. Instead of directly importing each database
and designing graph structures around it, we first define a liver disease
progression ontology with standard entity types, relation types, evidence rules,
and disease-stage constraints. The final `ontology_v1.0.yaml` should be
understood as the result of incremental schema evolution: DisGeNET first,
then STRING, KEGG, HMDB, Reactome, Human Protein Atlas, and finally
PubMed/LLM-derived candidate knowledge.

## Why This Is Better

The ontology-first design makes the project more consistent and easier to
explain. Different biomedical databases describe different types of
relationships: DisGeNET mainly provides gene-disease associations, STRING
provides protein-protein interactions, KEGG introduces the first pathway layer,
HMDB adds metabolite information, Reactome expands pathway hierarchy and
participants, and Human Protein Atlas provides tissue and cell-type expression
context. Without an ontology, each database may lead to a different graph
structure. With an ontology, every new source validates or extends the same
shared schema.

## Revised Technical Route

```text
Ontology construction
  -> incremental schema validation
  -> source-to-ontology mapping
  -> multi-source knowledge graph construction
  -> LLM-assisted literature extraction and graph enrichment
  -> graph learning / link prediction
```

## Role of the YAML

`ontology_v1.0.yaml` is a draft ontology specification and the current
consolidated result of the v0.1-v0.7 construction process. It defines the main
biomedical entities, allowed relations, disease progression stages, evidence
rules, and candidate knowledge handling. It is not just a data format; it is the
project-level schema that controls how external databases and LLM-extracted
knowledge enter the graph.

## Important Point About LLM and GNN

LLM and GNN should not be the first step. LLM extraction should be used after
the ontology exists, so extracted triples can be normalized into known entity
and relation types. Graph learning should be used after the knowledge graph is
stable, so predicted links can be stored as candidate relationships rather than
treated as confirmed biomedical facts.
