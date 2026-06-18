-- Run this after connecting to database fyp_ontology.
CREATE SCHEMA IF NOT EXISTS "ontology";
SET search_path TO "ontology";

DROP TABLE IF EXISTS "validation_status_values" CASCADE;
DROP TABLE IF EXISTS "tissues" CASCADE;
DROP TABLE IF EXISTS "subpathway_of_relations" CASCADE;
DROP TABLE IF EXISTS "source_mappings" CASCADE;
DROP TABLE IF EXISTS "relation_provenance_fields" CASCADE;
DROP TABLE IF EXISTS "relation_attributes" CASCADE;
DROP TABLE IF EXISTS "relation_allowed_sources" CASCADE;
DROP TABLE IF EXISTS "proteins" CASCADE;
DROP TABLE IF EXISTS "progresses_to_relations" CASCADE;
DROP TABLE IF EXISTS "pathways" CASCADE;
DROP TABLE IF EXISTS "participates_in_relations" CASCADE;
DROP TABLE IF EXISTS "ontology_use_cases" CASCADE;
DROP TABLE IF EXISTS "ontology_relations" CASCADE;
DROP TABLE IF EXISTS "ontology_metadata" CASCADE;
DROP TABLE IF EXISTS "ontology_entities" CASCADE;
DROP TABLE IF EXISTS "ontology_design_principles" CASCADE;
DROP TABLE IF EXISTS "metabolites" CASCADE;
DROP TABLE IF EXISTS "located_in_relations" CASCADE;
DROP TABLE IF EXISTS "llm_extracted_triple_fields" CASCADE;
DROP TABLE IF EXISTS "llm_allowed_relation_targets" CASCADE;
DROP TABLE IF EXISTS "involved_in_relations" CASCADE;
DROP TABLE IF EXISTS "involved_in_pathway_relations" CASCADE;
DROP TABLE IF EXISTS "involved_in_disease_relations" CASCADE;
DROP TABLE IF EXISTS "interacts_with_relations" CASCADE;
DROP TABLE IF EXISTS "identifier_policy_notes" CASCADE;
DROP TABLE IF EXISTS "identifier_policy_fields" CASCADE;
DROP TABLE IF EXISTS "graph_candidate_prediction_fields" CASCADE;
DROP TABLE IF EXISTS "graph_allowed_prediction_tasks" CASCADE;
DROP TABLE IF EXISTS "genes" CASCADE;
DROP TABLE IF EXISTS "expressed_in_tissue_relations" CASCADE;
DROP TABLE IF EXISTS "expressed_in_celltype_relations" CASCADE;
DROP TABLE IF EXISTS "evidence_levels" CASCADE;
DROP TABLE IF EXISTS "entity_primary_id_candidates" CASCADE;
DROP TABLE IF EXISTS "entity_attributes" CASCADE;
DROP TABLE IF EXISTS "encodes_relations" CASCADE;
DROP TABLE IF EXISTS "diseases" CASCADE;
DROP TABLE IF EXISTS "disease_stages" CASCADE;
DROP TABLE IF EXISTS "cell_types" CASCADE;
DROP TABLE IF EXISTS "canonical_progression_edges" CASCADE;
DROP TABLE IF EXISTS "associated_with_relations" CASCADE;
DROP TABLE IF EXISTS "associated_with_pathogenesis_relations" CASCADE;
DROP TABLE IF EXISTS "associated_with_metabolic_change_relations" CASCADE;

CREATE TABLE "associated_with_metabolic_change_relations" ("id" BIGSERIAL PRIMARY KEY, "metabolite_id" TEXT NOT NULL, "disease_id" TEXT NOT NULL, "change_direction" TEXT, "evidence_level" TEXT, "source" TEXT, "publication_id" TEXT, "evidence_text" TEXT, "date" TEXT, "sample_type" TEXT, "concentration" TEXT, "validation_status" TEXT, "extraction_method" TEXT, "confidence_score" TEXT, "notes" TEXT, "created_at" TEXT, "updated_at" TEXT);

CREATE TABLE "associated_with_pathogenesis_relations" ("id" BIGSERIAL PRIMARY KEY, "pathway_id" TEXT NOT NULL, "disease_id" TEXT NOT NULL, "evidence_level" TEXT, "source" TEXT, "publication_id" TEXT, "evidence_text" TEXT, "date" TEXT, "mechanism_description" TEXT, "validation_status" TEXT, "extraction_method" TEXT, "confidence_score" TEXT, "notes" TEXT, "created_at" TEXT, "updated_at" TEXT);

CREATE TABLE "associated_with_relations" ("id" BIGSERIAL PRIMARY KEY, "gene_id" TEXT NOT NULL, "disease_id" TEXT NOT NULL, "association_type" TEXT, "score" TEXT, "evidence_level" TEXT, "source" TEXT, "publication_id" TEXT, "evidence_text" TEXT, "date" TEXT, "source_record_id" TEXT, "validation_status" TEXT, "extraction_method" TEXT, "confidence_score" TEXT, "notes" TEXT, "created_at" TEXT, "updated_at" TEXT);

CREATE TABLE "canonical_progression_edges" ("source" TEXT NOT NULL, "target" TEXT NOT NULL, "relation" TEXT NOT NULL);

CREATE TABLE "cell_types" ("id" BIGSERIAL PRIMARY KEY, "cell_type_id" TEXT, "cell_type_name" TEXT, "source" TEXT, "project_id" TEXT, "external_ids" TEXT, "synonyms" TEXT, "tissue_context" TEXT, "description" TEXT, "created_at" TEXT, "updated_at" TEXT);

CREATE TABLE "disease_stages" ("stage_id" TEXT NOT NULL, "name" TEXT NOT NULL, "stage_order" INTEGER, "disease_name" TEXT, "is_progression_stage" INTEGER, PRIMARY KEY ("stage_id"));

CREATE TABLE "diseases" ("id" BIGSERIAL PRIMARY KEY, "disease_id" TEXT, "disease_name" TEXT, "umls_id" TEXT, "project_id" TEXT, "mesh_id" TEXT, "omim_id" TEXT, "synonyms" TEXT, "is_progression_stage" TEXT, "stage_order" TEXT, "disease_type" TEXT, "clinical_stage_definition" TEXT, "description" TEXT, "created_at" TEXT, "updated_at" TEXT);

CREATE TABLE "encodes_relations" ("id" BIGSERIAL PRIMARY KEY, "gene_id" TEXT NOT NULL, "protein_id" TEXT NOT NULL, "source" TEXT, "evidence_level" TEXT, "date" TEXT, "source_record_id" TEXT, "validation_status" TEXT, "notes" TEXT, "created_at" TEXT, "updated_at" TEXT);

CREATE TABLE "entity_attributes" ("entity_type" TEXT NOT NULL, "attribute_group" TEXT NOT NULL, "position" INTEGER NOT NULL, "attribute_name" TEXT NOT NULL, PRIMARY KEY ("entity_type", "attribute_group", "position"));

CREATE TABLE "entity_primary_id_candidates" ("entity_type" TEXT NOT NULL, "position" INTEGER NOT NULL, "candidate" TEXT NOT NULL, PRIMARY KEY ("entity_type", "position"));

CREATE TABLE "evidence_levels" ("evidence_level" TEXT NOT NULL, "description" TEXT NOT NULL, PRIMARY KEY ("evidence_level"));

CREATE TABLE "expressed_in_celltype_relations" ("id" BIGSERIAL PRIMARY KEY, "protein_id" TEXT NOT NULL, "cell_type_id" TEXT NOT NULL, "expression_level" TEXT, "source" TEXT, "date" TEXT, "expression_score" TEXT, "evidence_level" TEXT, "source_record_id" TEXT, "validation_status" TEXT, "notes" TEXT, "created_at" TEXT, "updated_at" TEXT);

CREATE TABLE "expressed_in_tissue_relations" ("id" BIGSERIAL PRIMARY KEY, "protein_id" TEXT NOT NULL, "tissue_id" TEXT NOT NULL, "expression_level" TEXT, "source" TEXT, "date" TEXT, "expression_score" TEXT, "evidence_level" TEXT, "source_record_id" TEXT, "validation_status" TEXT, "notes" TEXT, "created_at" TEXT, "updated_at" TEXT);

CREATE TABLE "genes" ("id" BIGSERIAL PRIMARY KEY, "gene_id" TEXT, "gene_symbol" TEXT, "gene_name" TEXT, "project_id" TEXT, "primary_external_id" TEXT, "external_ids" TEXT, "synonyms" TEXT, "source" TEXT, "chromosome_location" TEXT, "gene_type" TEXT, "organism" TEXT, "created_at" TEXT, "updated_at" TEXT);

CREATE TABLE "graph_allowed_prediction_tasks" ("position" INTEGER NOT NULL, "task_name" TEXT NOT NULL, PRIMARY KEY ("position"));

CREATE TABLE "graph_candidate_prediction_fields" ("position" INTEGER NOT NULL, "field_name" TEXT NOT NULL, PRIMARY KEY ("position"));

CREATE TABLE "identifier_policy_fields" ("position" INTEGER NOT NULL, "field_name" TEXT NOT NULL, PRIMARY KEY ("position"));

CREATE TABLE "identifier_policy_notes" ("position" INTEGER NOT NULL, "note" TEXT NOT NULL, PRIMARY KEY ("position"));

CREATE TABLE "interacts_with_relations" ("id" BIGSERIAL PRIMARY KEY, "protein_id" TEXT NOT NULL, "protein_id_2" TEXT NOT NULL, "combined_score" TEXT, "experimental_score" TEXT, "database_score" TEXT, "textmining_score" TEXT, "coexpression_score" TEXT, "source" TEXT, "date" TEXT, "evidence_level" TEXT, "source_record_id" TEXT, "validation_status" TEXT, "notes" TEXT, "created_at" TEXT, "updated_at" TEXT);

CREATE TABLE "involved_in_disease_relations" ("id" BIGSERIAL PRIMARY KEY, "cell_type_id" TEXT NOT NULL, "disease_id" TEXT NOT NULL, "role" TEXT, "source" TEXT, "evidence_level" TEXT, "publication_id" TEXT, "evidence_text" TEXT, "date" TEXT, "validation_status" TEXT, "extraction_method" TEXT, "confidence_score" TEXT, "notes" TEXT, "created_at" TEXT, "updated_at" TEXT);

CREATE TABLE "involved_in_pathway_relations" ("id" BIGSERIAL PRIMARY KEY, "metabolite_id" TEXT NOT NULL, "pathway_id" TEXT NOT NULL, "role" TEXT, "source" TEXT, "evidence_level" TEXT, "date" TEXT, "source_record_id" TEXT, "validation_status" TEXT, "notes" TEXT, "created_at" TEXT, "updated_at" TEXT);

CREATE TABLE "involved_in_relations" ("id" BIGSERIAL PRIMARY KEY, "protein_id" TEXT NOT NULL, "pathway_id" TEXT NOT NULL, "role" TEXT, "source" TEXT, "evidence_level" TEXT, "date" TEXT, "source_record_id" TEXT, "validation_status" TEXT, "notes" TEXT, "created_at" TEXT, "updated_at" TEXT);

CREATE TABLE "llm_allowed_relation_targets" ("position" INTEGER NOT NULL, "relation_type" TEXT NOT NULL, PRIMARY KEY ("position"));

CREATE TABLE "llm_extracted_triple_fields" ("position" INTEGER NOT NULL, "field_name" TEXT NOT NULL, PRIMARY KEY ("position"));

CREATE TABLE "located_in_relations" ("id" BIGSERIAL PRIMARY KEY, "cell_type_id" TEXT NOT NULL, "tissue_id" TEXT NOT NULL, "source" TEXT, "evidence_level" TEXT, "date" TEXT, "source_record_id" TEXT, "validation_status" TEXT, "notes" TEXT, "created_at" TEXT, "updated_at" TEXT);

CREATE TABLE "metabolites" ("id" BIGSERIAL PRIMARY KEY, "metabolite_id" TEXT, "metabolite_name" TEXT, "chemical_formula" TEXT, "molecular_weight" TEXT, "source" TEXT, "project_id" TEXT, "external_ids" TEXT, "synonyms" TEXT, "smiles" TEXT, "inchikey" TEXT, "metabolite_class" TEXT, "description" TEXT, "created_at" TEXT, "updated_at" TEXT);

CREATE TABLE "ontology_design_principles" ("position" INTEGER NOT NULL, "principle" TEXT NOT NULL, PRIMARY KEY ("position"));

CREATE TABLE "ontology_entities" ("entity_type" TEXT NOT NULL, "description" TEXT, PRIMARY KEY ("entity_type"));

CREATE TABLE "ontology_metadata" ("key" TEXT NOT NULL, "value" TEXT, PRIMARY KEY ("key"));

CREATE TABLE "ontology_relations" ("relation_type" TEXT NOT NULL, "source_entity_type" TEXT NOT NULL, "target_entity_type" TEXT NOT NULL, "direction" TEXT, "symmetric" INTEGER, "description" TEXT, PRIMARY KEY ("relation_type"));

CREATE TABLE "ontology_use_cases" ("position" INTEGER NOT NULL, "use_case" TEXT NOT NULL, PRIMARY KEY ("position"));

CREATE TABLE "participates_in_relations" ("id" BIGSERIAL PRIMARY KEY, "gene_id" TEXT NOT NULL, "pathway_id" TEXT NOT NULL, "role" TEXT, "source" TEXT, "evidence_level" TEXT, "date" TEXT, "source_record_id" TEXT, "validation_status" TEXT, "notes" TEXT, "created_at" TEXT, "updated_at" TEXT);

CREATE TABLE "pathways" ("id" BIGSERIAL PRIMARY KEY, "pathway_id" TEXT, "pathway_name" TEXT, "pathway_category" TEXT, "pathway_source" TEXT, "source" TEXT, "project_id" TEXT, "external_ids" TEXT, "synonyms" TEXT, "pathway_description" TEXT, "created_at" TEXT, "updated_at" TEXT);

CREATE TABLE "progresses_to_relations" ("id" BIGSERIAL PRIMARY KEY, "disease_id" TEXT NOT NULL, "disease_id_2" TEXT NOT NULL, "relationship_type" TEXT, "evidence_level" TEXT, "source" TEXT, "publication_id" TEXT, "evidence_text" TEXT, "date" TEXT, "stage_order_delta" TEXT, "validation_status" TEXT, "notes" TEXT, "created_at" TEXT, "updated_at" TEXT);

CREATE TABLE "proteins" ("id" BIGSERIAL PRIMARY KEY, "protein_id" TEXT, "protein_symbol" TEXT, "protein_name" TEXT, "organism" TEXT, "project_id" TEXT, "primary_external_id" TEXT, "external_ids" TEXT, "synonyms" TEXT, "taxonomy_id" TEXT, "encoded_by_gene_id" TEXT, "created_at" TEXT, "updated_at" TEXT);

CREATE TABLE "relation_allowed_sources" ("relation_type" TEXT NOT NULL, "position" INTEGER NOT NULL, "allowed_source" TEXT NOT NULL, PRIMARY KEY ("relation_type", "position"));

CREATE TABLE "relation_attributes" ("relation_type" TEXT NOT NULL, "attribute_group" TEXT NOT NULL, "position" INTEGER NOT NULL, "attribute_name" TEXT NOT NULL, PRIMARY KEY ("relation_type", "attribute_group", "position"));

CREATE TABLE "relation_provenance_fields" ("field_group" TEXT NOT NULL, "position" INTEGER NOT NULL, "field_name" TEXT NOT NULL, PRIMARY KEY ("field_group", "position"));

CREATE TABLE "source_mappings" ("source" TEXT NOT NULL, "main_content" TEXT, "ontology_entities" TEXT, "ontology_relations" TEXT, "key_fields_to_preserve" TEXT, "notes" TEXT, PRIMARY KEY ("source"));

CREATE TABLE "subpathway_of_relations" ("id" BIGSERIAL PRIMARY KEY, "pathway_id" TEXT NOT NULL, "pathway_id_2" TEXT NOT NULL, "source" TEXT, "evidence_level" TEXT, "date" TEXT, "source_record_id" TEXT, "validation_status" TEXT, "notes" TEXT, "created_at" TEXT, "updated_at" TEXT);

CREATE TABLE "tissues" ("id" BIGSERIAL PRIMARY KEY, "tissue_id" TEXT, "tissue_name" TEXT, "organ_system" TEXT, "source" TEXT, "project_id" TEXT, "external_ids" TEXT, "synonyms" TEXT, "description" TEXT, "created_at" TEXT, "updated_at" TEXT);

CREATE TABLE "validation_status_values" ("position" INTEGER NOT NULL, "status_value" TEXT NOT NULL, PRIMARY KEY ("position"));

INSERT INTO "canonical_progression_edges" ("source", "target", "relation") VALUES ('Healthy liver', 'NAFLD', 'progresses_to');
INSERT INTO "canonical_progression_edges" ("source", "target", "relation") VALUES ('NAFLD', 'NASH', 'progresses_to');
INSERT INTO "canonical_progression_edges" ("source", "target", "relation") VALUES ('NASH', 'Fibrosis', 'progresses_to');
INSERT INTO "canonical_progression_edges" ("source", "target", "relation") VALUES ('Fibrosis', 'Cirrhosis', 'progresses_to');
INSERT INTO "canonical_progression_edges" ("source", "target", "relation") VALUES ('Cirrhosis', 'HCC', 'progresses_to');

INSERT INTO "disease_stages" ("stage_id", "name", "stage_order", "disease_name", "is_progression_stage") VALUES ('LD_STAGE_00', 'Healthy liver', 0, 'Healthy liver', 1);
INSERT INTO "disease_stages" ("stage_id", "name", "stage_order", "disease_name", "is_progression_stage") VALUES ('LD_STAGE_01', 'NAFLD', 1, 'Non-alcoholic fatty liver disease', 1);
INSERT INTO "disease_stages" ("stage_id", "name", "stage_order", "disease_name", "is_progression_stage") VALUES ('LD_STAGE_02', 'NASH', 2, 'Non-alcoholic steatohepatitis', 1);
INSERT INTO "disease_stages" ("stage_id", "name", "stage_order", "disease_name", "is_progression_stage") VALUES ('LD_STAGE_03', 'Fibrosis', 3, 'Liver fibrosis', 1);
INSERT INTO "disease_stages" ("stage_id", "name", "stage_order", "disease_name", "is_progression_stage") VALUES ('LD_STAGE_04', 'Cirrhosis', 4, 'Liver cirrhosis', 1);
INSERT INTO "disease_stages" ("stage_id", "name", "stage_order", "disease_name", "is_progression_stage") VALUES ('LD_STAGE_05', 'HCC', 5, 'Hepatocellular carcinoma', 1);

INSERT INTO "diseases" ("id", "disease_id", "disease_name", "umls_id", "project_id", "mesh_id", "omim_id", "synonyms", "is_progression_stage", "stage_order", "disease_type", "clinical_stage_definition", "description", "created_at", "updated_at") VALUES (1, 'LD_STAGE_00', 'Healthy liver', NULL, 'LD_STAGE_00', NULL, NULL, 'Healthy liver', '1', '0', NULL, NULL, NULL, NULL, NULL);
INSERT INTO "diseases" ("id", "disease_id", "disease_name", "umls_id", "project_id", "mesh_id", "omim_id", "synonyms", "is_progression_stage", "stage_order", "disease_type", "clinical_stage_definition", "description", "created_at", "updated_at") VALUES (2, 'LD_STAGE_01', 'Non-alcoholic fatty liver disease', NULL, 'LD_STAGE_01', NULL, NULL, 'NAFLD', '1', '1', NULL, NULL, NULL, NULL, NULL);
INSERT INTO "diseases" ("id", "disease_id", "disease_name", "umls_id", "project_id", "mesh_id", "omim_id", "synonyms", "is_progression_stage", "stage_order", "disease_type", "clinical_stage_definition", "description", "created_at", "updated_at") VALUES (3, 'LD_STAGE_02', 'Non-alcoholic steatohepatitis', NULL, 'LD_STAGE_02', NULL, NULL, 'NASH', '1', '2', NULL, NULL, NULL, NULL, NULL);
INSERT INTO "diseases" ("id", "disease_id", "disease_name", "umls_id", "project_id", "mesh_id", "omim_id", "synonyms", "is_progression_stage", "stage_order", "disease_type", "clinical_stage_definition", "description", "created_at", "updated_at") VALUES (4, 'LD_STAGE_03', 'Liver fibrosis', NULL, 'LD_STAGE_03', NULL, NULL, 'Fibrosis', '1', '3', NULL, NULL, NULL, NULL, NULL);
INSERT INTO "diseases" ("id", "disease_id", "disease_name", "umls_id", "project_id", "mesh_id", "omim_id", "synonyms", "is_progression_stage", "stage_order", "disease_type", "clinical_stage_definition", "description", "created_at", "updated_at") VALUES (5, 'LD_STAGE_04', 'Liver cirrhosis', NULL, 'LD_STAGE_04', NULL, NULL, 'Cirrhosis', '1', '4', NULL, NULL, NULL, NULL, NULL);
INSERT INTO "diseases" ("id", "disease_id", "disease_name", "umls_id", "project_id", "mesh_id", "omim_id", "synonyms", "is_progression_stage", "stage_order", "disease_type", "clinical_stage_definition", "description", "created_at", "updated_at") VALUES (6, 'LD_STAGE_05', 'Hepatocellular carcinoma', NULL, 'LD_STAGE_05', NULL, NULL, 'HCC', '1', '5', NULL, NULL, NULL, NULL, NULL);

INSERT INTO "entity_attributes" ("entity_type", "attribute_group", "position", "attribute_name") VALUES ('Gene', 'confirmed', 1, 'gene_id');
INSERT INTO "entity_attributes" ("entity_type", "attribute_group", "position", "attribute_name") VALUES ('Gene', 'confirmed', 2, 'gene_symbol');
INSERT INTO "entity_attributes" ("entity_type", "attribute_group", "position", "attribute_name") VALUES ('Gene', 'confirmed', 3, 'gene_name');
INSERT INTO "entity_attributes" ("entity_type", "attribute_group", "position", "attribute_name") VALUES ('Gene', 'recommended', 1, 'project_id');
INSERT INTO "entity_attributes" ("entity_type", "attribute_group", "position", "attribute_name") VALUES ('Gene', 'recommended', 2, 'primary_external_id');
INSERT INTO "entity_attributes" ("entity_type", "attribute_group", "position", "attribute_name") VALUES ('Gene', 'recommended', 3, 'external_ids');
INSERT INTO "entity_attributes" ("entity_type", "attribute_group", "position", "attribute_name") VALUES ('Gene', 'recommended', 4, 'synonyms');
INSERT INTO "entity_attributes" ("entity_type", "attribute_group", "position", "attribute_name") VALUES ('Gene', 'recommended', 5, 'source');
INSERT INTO "entity_attributes" ("entity_type", "attribute_group", "position", "attribute_name") VALUES ('Gene', 'planned', 1, 'chromosome_location');
INSERT INTO "entity_attributes" ("entity_type", "attribute_group", "position", "attribute_name") VALUES ('Gene', 'planned', 2, 'gene_type');
INSERT INTO "entity_attributes" ("entity_type", "attribute_group", "position", "attribute_name") VALUES ('Gene', 'planned', 3, 'organism');
INSERT INTO "entity_attributes" ("entity_type", "attribute_group", "position", "attribute_name") VALUES ('Disease', 'confirmed', 1, 'disease_id');
INSERT INTO "entity_attributes" ("entity_type", "attribute_group", "position", "attribute_name") VALUES ('Disease', 'confirmed', 2, 'disease_name');
INSERT INTO "entity_attributes" ("entity_type", "attribute_group", "position", "attribute_name") VALUES ('Disease', 'confirmed', 3, 'umls_id');
INSERT INTO "entity_attributes" ("entity_type", "attribute_group", "position", "attribute_name") VALUES ('Disease', 'recommended', 1, 'project_id');
INSERT INTO "entity_attributes" ("entity_type", "attribute_group", "position", "attribute_name") VALUES ('Disease', 'recommended', 2, 'mesh_id');
INSERT INTO "entity_attributes" ("entity_type", "attribute_group", "position", "attribute_name") VALUES ('Disease', 'recommended', 3, 'omim_id');
INSERT INTO "entity_attributes" ("entity_type", "attribute_group", "position", "attribute_name") VALUES ('Disease', 'recommended', 4, 'synonyms');
INSERT INTO "entity_attributes" ("entity_type", "attribute_group", "position", "attribute_name") VALUES ('Disease', 'recommended', 5, 'is_progression_stage');
INSERT INTO "entity_attributes" ("entity_type", "attribute_group", "position", "attribute_name") VALUES ('Disease', 'recommended', 6, 'stage_order');
INSERT INTO "entity_attributes" ("entity_type", "attribute_group", "position", "attribute_name") VALUES ('Disease', 'planned', 1, 'disease_type');
INSERT INTO "entity_attributes" ("entity_type", "attribute_group", "position", "attribute_name") VALUES ('Disease', 'planned', 2, 'clinical_stage_definition');
INSERT INTO "entity_attributes" ("entity_type", "attribute_group", "position", "attribute_name") VALUES ('Disease', 'planned', 3, 'description');
INSERT INTO "entity_attributes" ("entity_type", "attribute_group", "position", "attribute_name") VALUES ('Protein', 'confirmed', 1, 'protein_id');
INSERT INTO "entity_attributes" ("entity_type", "attribute_group", "position", "attribute_name") VALUES ('Protein', 'confirmed', 2, 'protein_symbol');
INSERT INTO "entity_attributes" ("entity_type", "attribute_group", "position", "attribute_name") VALUES ('Protein', 'confirmed', 3, 'protein_name');
INSERT INTO "entity_attributes" ("entity_type", "attribute_group", "position", "attribute_name") VALUES ('Protein', 'confirmed', 4, 'organism');
INSERT INTO "entity_attributes" ("entity_type", "attribute_group", "position", "attribute_name") VALUES ('Protein', 'recommended', 1, 'project_id');
INSERT INTO "entity_attributes" ("entity_type", "attribute_group", "position", "attribute_name") VALUES ('Protein', 'recommended', 2, 'primary_external_id');
INSERT INTO "entity_attributes" ("entity_type", "attribute_group", "position", "attribute_name") VALUES ('Protein', 'recommended', 3, 'external_ids');
INSERT INTO "entity_attributes" ("entity_type", "attribute_group", "position", "attribute_name") VALUES ('Protein', 'recommended', 4, 'synonyms');
INSERT INTO "entity_attributes" ("entity_type", "attribute_group", "position", "attribute_name") VALUES ('Protein', 'planned', 1, 'taxonomy_id');
INSERT INTO "entity_attributes" ("entity_type", "attribute_group", "position", "attribute_name") VALUES ('Protein', 'planned', 2, 'encoded_by_gene_id');
INSERT INTO "entity_attributes" ("entity_type", "attribute_group", "position", "attribute_name") VALUES ('Pathway', 'confirmed', 1, 'pathway_id');
INSERT INTO "entity_attributes" ("entity_type", "attribute_group", "position", "attribute_name") VALUES ('Pathway', 'confirmed', 2, 'pathway_name');
INSERT INTO "entity_attributes" ("entity_type", "attribute_group", "position", "attribute_name") VALUES ('Pathway', 'confirmed', 3, 'pathway_category');
INSERT INTO "entity_attributes" ("entity_type", "attribute_group", "position", "attribute_name") VALUES ('Pathway', 'confirmed', 4, 'pathway_source');
INSERT INTO "entity_attributes" ("entity_type", "attribute_group", "position", "attribute_name") VALUES ('Pathway', 'confirmed', 5, 'source');
INSERT INTO "entity_attributes" ("entity_type", "attribute_group", "position", "attribute_name") VALUES ('Pathway', 'recommended', 1, 'project_id');
INSERT INTO "entity_attributes" ("entity_type", "attribute_group", "position", "attribute_name") VALUES ('Pathway', 'recommended', 2, 'external_ids');
INSERT INTO "entity_attributes" ("entity_type", "attribute_group", "position", "attribute_name") VALUES ('Pathway', 'recommended', 3, 'synonyms');
INSERT INTO "entity_attributes" ("entity_type", "attribute_group", "position", "attribute_name") VALUES ('Pathway', 'planned', 1, 'pathway_description');
INSERT INTO "entity_attributes" ("entity_type", "attribute_group", "position", "attribute_name") VALUES ('Metabolite', 'confirmed', 1, 'metabolite_id');
INSERT INTO "entity_attributes" ("entity_type", "attribute_group", "position", "attribute_name") VALUES ('Metabolite', 'confirmed', 2, 'metabolite_name');
INSERT INTO "entity_attributes" ("entity_type", "attribute_group", "position", "attribute_name") VALUES ('Metabolite', 'confirmed', 3, 'chemical_formula');
INSERT INTO "entity_attributes" ("entity_type", "attribute_group", "position", "attribute_name") VALUES ('Metabolite', 'confirmed', 4, 'molecular_weight');
INSERT INTO "entity_attributes" ("entity_type", "attribute_group", "position", "attribute_name") VALUES ('Metabolite', 'confirmed', 5, 'source');
INSERT INTO "entity_attributes" ("entity_type", "attribute_group", "position", "attribute_name") VALUES ('Metabolite', 'recommended', 1, 'project_id');
INSERT INTO "entity_attributes" ("entity_type", "attribute_group", "position", "attribute_name") VALUES ('Metabolite', 'recommended', 2, 'external_ids');
INSERT INTO "entity_attributes" ("entity_type", "attribute_group", "position", "attribute_name") VALUES ('Metabolite', 'recommended', 3, 'synonyms');
INSERT INTO "entity_attributes" ("entity_type", "attribute_group", "position", "attribute_name") VALUES ('Metabolite', 'planned', 1, 'smiles');
INSERT INTO "entity_attributes" ("entity_type", "attribute_group", "position", "attribute_name") VALUES ('Metabolite', 'planned', 2, 'inchikey');
INSERT INTO "entity_attributes" ("entity_type", "attribute_group", "position", "attribute_name") VALUES ('Metabolite', 'planned', 3, 'metabolite_class');
INSERT INTO "entity_attributes" ("entity_type", "attribute_group", "position", "attribute_name") VALUES ('Metabolite', 'planned', 4, 'description');
INSERT INTO "entity_attributes" ("entity_type", "attribute_group", "position", "attribute_name") VALUES ('Tissue', 'confirmed', 1, 'tissue_id');
INSERT INTO "entity_attributes" ("entity_type", "attribute_group", "position", "attribute_name") VALUES ('Tissue', 'confirmed', 2, 'tissue_name');
INSERT INTO "entity_attributes" ("entity_type", "attribute_group", "position", "attribute_name") VALUES ('Tissue', 'confirmed', 3, 'organ_system');
INSERT INTO "entity_attributes" ("entity_type", "attribute_group", "position", "attribute_name") VALUES ('Tissue', 'confirmed', 4, 'source');
INSERT INTO "entity_attributes" ("entity_type", "attribute_group", "position", "attribute_name") VALUES ('Tissue', 'recommended', 1, 'project_id');
INSERT INTO "entity_attributes" ("entity_type", "attribute_group", "position", "attribute_name") VALUES ('Tissue', 'recommended', 2, 'external_ids');
INSERT INTO "entity_attributes" ("entity_type", "attribute_group", "position", "attribute_name") VALUES ('Tissue', 'recommended', 3, 'synonyms');
INSERT INTO "entity_attributes" ("entity_type", "attribute_group", "position", "attribute_name") VALUES ('Tissue', 'planned', 1, 'description');
INSERT INTO "entity_attributes" ("entity_type", "attribute_group", "position", "attribute_name") VALUES ('CellType', 'confirmed', 1, 'cell_type_id');
INSERT INTO "entity_attributes" ("entity_type", "attribute_group", "position", "attribute_name") VALUES ('CellType', 'confirmed', 2, 'cell_type_name');
INSERT INTO "entity_attributes" ("entity_type", "attribute_group", "position", "attribute_name") VALUES ('CellType', 'confirmed', 3, 'source');
INSERT INTO "entity_attributes" ("entity_type", "attribute_group", "position", "attribute_name") VALUES ('CellType', 'recommended', 1, 'project_id');
INSERT INTO "entity_attributes" ("entity_type", "attribute_group", "position", "attribute_name") VALUES ('CellType', 'recommended', 2, 'external_ids');
INSERT INTO "entity_attributes" ("entity_type", "attribute_group", "position", "attribute_name") VALUES ('CellType', 'recommended', 3, 'synonyms');
INSERT INTO "entity_attributes" ("entity_type", "attribute_group", "position", "attribute_name") VALUES ('CellType', 'planned', 1, 'tissue_context');
INSERT INTO "entity_attributes" ("entity_type", "attribute_group", "position", "attribute_name") VALUES ('CellType', 'planned', 2, 'description');

INSERT INTO "entity_primary_id_candidates" ("entity_type", "position", "candidate") VALUES ('Gene', 1, 'NCBI Gene ID');
INSERT INTO "entity_primary_id_candidates" ("entity_type", "position", "candidate") VALUES ('Gene', 2, 'HGNC ID');
INSERT INTO "entity_primary_id_candidates" ("entity_type", "position", "candidate") VALUES ('Disease', 1, 'UMLS CUI');
INSERT INTO "entity_primary_id_candidates" ("entity_type", "position", "candidate") VALUES ('Disease', 2, 'MeSH ID');
INSERT INTO "entity_primary_id_candidates" ("entity_type", "position", "candidate") VALUES ('Disease', 3, 'OMIM ID');
INSERT INTO "entity_primary_id_candidates" ("entity_type", "position", "candidate") VALUES ('Disease', 4, 'project stage ID');
INSERT INTO "entity_primary_id_candidates" ("entity_type", "position", "candidate") VALUES ('Protein', 1, 'UniProt accession');
INSERT INTO "entity_primary_id_candidates" ("entity_type", "position", "candidate") VALUES ('Protein', 2, 'STRING protein ID');
INSERT INTO "entity_primary_id_candidates" ("entity_type", "position", "candidate") VALUES ('Pathway', 1, 'KEGG pathway ID');
INSERT INTO "entity_primary_id_candidates" ("entity_type", "position", "candidate") VALUES ('Pathway', 2, 'Reactome stable ID');
INSERT INTO "entity_primary_id_candidates" ("entity_type", "position", "candidate") VALUES ('Metabolite', 1, 'HMDB ID');
INSERT INTO "entity_primary_id_candidates" ("entity_type", "position", "candidate") VALUES ('Metabolite', 2, 'KEGG Compound ID');
INSERT INTO "entity_primary_id_candidates" ("entity_type", "position", "candidate") VALUES ('Metabolite', 3, 'PubChem CID');
INSERT INTO "entity_primary_id_candidates" ("entity_type", "position", "candidate") VALUES ('Metabolite', 4, 'InChIKey');
INSERT INTO "entity_primary_id_candidates" ("entity_type", "position", "candidate") VALUES ('Tissue', 1, 'HPA tissue name');
INSERT INTO "entity_primary_id_candidates" ("entity_type", "position", "candidate") VALUES ('Tissue', 2, 'Uberon ID');
INSERT INTO "entity_primary_id_candidates" ("entity_type", "position", "candidate") VALUES ('CellType', 1, 'HPA cell type name');
INSERT INTO "entity_primary_id_candidates" ("entity_type", "position", "candidate") VALUES ('CellType', 2, 'Cell Ontology ID');

INSERT INTO "evidence_levels" ("evidence_level", "description") VALUES ('curated_database', 'Relationship imported from a curated or semi-curated biomedical database.');
INSERT INTO "evidence_levels" ("evidence_level", "description") VALUES ('literature_supported', 'Relationship supported by publication evidence.');
INSERT INTO "evidence_levels" ("evidence_level", "description") VALUES ('llm_extracted_candidate', 'Candidate relationship extracted from text by an LLM and requiring validation.');
INSERT INTO "evidence_levels" ("evidence_level", "description") VALUES ('predicted_candidate', 'Candidate relationship predicted by graph learning and requiring validation.');
INSERT INTO "evidence_levels" ("evidence_level", "description") VALUES ('manually_validated', 'Relationship checked by project members against source evidence.');

INSERT INTO "graph_allowed_prediction_tasks" ("position", "task_name") VALUES (1, 'Gene-Disease association prediction');
INSERT INTO "graph_allowed_prediction_tasks" ("position", "task_name") VALUES (2, 'Protein-Protein interaction candidate ranking');
INSERT INTO "graph_allowed_prediction_tasks" ("position", "task_name") VALUES (3, 'Metabolite-Disease association prediction');
INSERT INTO "graph_allowed_prediction_tasks" ("position", "task_name") VALUES (4, 'Pathway-Disease association prediction');

INSERT INTO "graph_candidate_prediction_fields" ("position", "field_name") VALUES (1, 'model_name');
INSERT INTO "graph_candidate_prediction_fields" ("position", "field_name") VALUES (2, 'model_version');
INSERT INTO "graph_candidate_prediction_fields" ("position", "field_name") VALUES (3, 'prediction_score');
INSERT INTO "graph_candidate_prediction_fields" ("position", "field_name") VALUES (4, 'rank');
INSERT INTO "graph_candidate_prediction_fields" ("position", "field_name") VALUES (5, 'training_graph_version');
INSERT INTO "graph_candidate_prediction_fields" ("position", "field_name") VALUES (6, 'validation_status');

INSERT INTO "identifier_policy_fields" ("position", "field_name") VALUES (1, 'project_id');
INSERT INTO "identifier_policy_fields" ("position", "field_name") VALUES (2, 'primary_external_id');
INSERT INTO "identifier_policy_fields" ("position", "field_name") VALUES (3, 'external_ids');
INSERT INTO "identifier_policy_fields" ("position", "field_name") VALUES (4, 'synonyms');
INSERT INTO "identifier_policy_fields" ("position", "field_name") VALUES (5, 'source');
INSERT INTO "identifier_policy_fields" ("position", "field_name") VALUES (6, 'source_record_id');

INSERT INTO "identifier_policy_notes" ("position", "note") VALUES (1, 'Gene identifiers should preferably be normalized to NCBI Gene or HGNC where possible.');
INSERT INTO "identifier_policy_notes" ("position", "note") VALUES (2, 'Protein identifiers should preferably be normalized to UniProt where possible.');
INSERT INTO "identifier_policy_notes" ("position", "note") VALUES (3, 'Disease identifiers should preferably keep UMLS, MeSH, OMIM, and source-specific IDs where available.');
INSERT INTO "identifier_policy_notes" ("position", "note") VALUES (4, 'Pathway identifiers should retain KEGG and Reactome stable IDs separately.');
INSERT INTO "identifier_policy_notes" ("position", "note") VALUES (5, 'Metabolite identifiers should retain HMDB, KEGG Compound, PubChem, InChIKey, and synonyms where available.');

INSERT INTO "llm_allowed_relation_targets" ("position", "relation_type") VALUES (1, 'associated_with');
INSERT INTO "llm_allowed_relation_targets" ("position", "relation_type") VALUES (2, 'associated_with_pathogenesis');
INSERT INTO "llm_allowed_relation_targets" ("position", "relation_type") VALUES (3, 'associated_with_metabolic_change');
INSERT INTO "llm_allowed_relation_targets" ("position", "relation_type") VALUES (4, 'involved_in_disease');
INSERT INTO "llm_allowed_relation_targets" ("position", "relation_type") VALUES (5, 'interacts_with');
INSERT INTO "llm_allowed_relation_targets" ("position", "relation_type") VALUES (6, 'participates_in');
INSERT INTO "llm_allowed_relation_targets" ("position", "relation_type") VALUES (7, 'involved_in');

INSERT INTO "llm_extracted_triple_fields" ("position", "field_name") VALUES (1, 'subject_text');
INSERT INTO "llm_extracted_triple_fields" ("position", "field_name") VALUES (2, 'subject_entity_type');
INSERT INTO "llm_extracted_triple_fields" ("position", "field_name") VALUES (3, 'relation_type');
INSERT INTO "llm_extracted_triple_fields" ("position", "field_name") VALUES (4, 'object_text');
INSERT INTO "llm_extracted_triple_fields" ("position", "field_name") VALUES (5, 'object_entity_type');
INSERT INTO "llm_extracted_triple_fields" ("position", "field_name") VALUES (6, 'evidence_text');
INSERT INTO "llm_extracted_triple_fields" ("position", "field_name") VALUES (7, 'publication_id');
INSERT INTO "llm_extracted_triple_fields" ("position", "field_name") VALUES (8, 'extraction_method');
INSERT INTO "llm_extracted_triple_fields" ("position", "field_name") VALUES (9, 'confidence_score');
INSERT INTO "llm_extracted_triple_fields" ("position", "field_name") VALUES (10, 'normalization_status');
INSERT INTO "llm_extracted_triple_fields" ("position", "field_name") VALUES (11, 'validation_status');

INSERT INTO "ontology_design_principles" ("position", "principle") VALUES (1, 'Define ontology classes and relations before importing database records.');
INSERT INTO "ontology_design_principles" ("position", "principle") VALUES (2, 'Map each external database into the same ontology rather than creating one graph per source.');
INSERT INTO "ontology_design_principles" ("position", "principle") VALUES (3, 'Keep curated database facts separate from LLM-extracted candidate knowledge.');
INSERT INTO "ontology_design_principles" ("position", "principle") VALUES (4, 'Preserve source, evidence, identifier, and extraction provenance for every relationship.');
INSERT INTO "ontology_design_principles" ("position", "principle") VALUES (5, 'Support downstream Neo4j querying, visualization, and graph learning.');

INSERT INTO "ontology_entities" ("entity_type", "description") VALUES ('Gene', 'Gene or gene locus relevant to liver disease biology.');
INSERT INTO "ontology_entities" ("entity_type", "description") VALUES ('Disease', 'Disease, phenotype, pathological condition, or canonical liver disease progression stage.');
INSERT INTO "ontology_entities" ("entity_type", "description") VALUES ('Protein', 'Protein product, preferably normalized to UniProt where possible.');
INSERT INTO "ontology_entities" ("entity_type", "description") VALUES ('Pathway', 'Biological pathway, metabolic pathway, or pathway hierarchy term.');
INSERT INTO "ontology_entities" ("entity_type", "description") VALUES ('Metabolite', 'Metabolite or chemical compound associated with liver disease metabolism.');
INSERT INTO "ontology_entities" ("entity_type", "description") VALUES ('Tissue', 'Tissue or anatomical context used for expression and pathology evidence.');
INSERT INTO "ontology_entities" ("entity_type", "description") VALUES ('CellType', 'Cell type relevant to liver tissue context, expression, inflammation, fibrosis, or tumor microenvironment.');

INSERT INTO "ontology_metadata" ("key", "value") VALUES ('name', 'Liver Disease Progression Ontology');
INSERT INTO "ontology_metadata" ("key", "value") VALUES ('version', '1.0-draft');
INSERT INTO "ontology_metadata" ("key", "value") VALUES ('description', 'An ontology-first schema for constructing a stage-aware biomedical knowledge graph of liver disease progression. The ontology defines core biomedical entity types, typed relationships, evidence/provenance requirements, disease-stage constraints, and source-to-ontology mapping rules for database integration and LLM-assisted graph enrichment.
');

INSERT INTO "ontology_relations" ("relation_type", "source_entity_type", "target_entity_type", "direction", "symmetric", "description") VALUES ('associated_with', 'Gene', 'Disease', 'directed', 0, 'Gene-disease association mainly derived from DisGeNET or literature.');
INSERT INTO "ontology_relations" ("relation_type", "source_entity_type", "target_entity_type", "direction", "symmetric", "description") VALUES ('progresses_to', 'Disease', 'Disease', 'directed', 0, 'Disease progression relationship among canonical liver disease stages.');
INSERT INTO "ontology_relations" ("relation_type", "source_entity_type", "target_entity_type", "direction", "symmetric", "description") VALUES ('encodes', 'Gene', 'Protein', 'directed', 0, 'Gene encodes protein relationship.');
INSERT INTO "ontology_relations" ("relation_type", "source_entity_type", "target_entity_type", "direction", "symmetric", "description") VALUES ('interacts_with', 'Protein', 'Protein', 'undirected', 1, 'Protein-protein interaction mainly derived from STRING.');
INSERT INTO "ontology_relations" ("relation_type", "source_entity_type", "target_entity_type", "direction", "symmetric", "description") VALUES ('participates_in', 'Gene', 'Pathway', 'directed', 0, 'Gene participates in a biological pathway.');
INSERT INTO "ontology_relations" ("relation_type", "source_entity_type", "target_entity_type", "direction", "symmetric", "description") VALUES ('involved_in', 'Protein', 'Pathway', 'directed', 0, 'Protein is involved in a biological pathway.');
INSERT INTO "ontology_relations" ("relation_type", "source_entity_type", "target_entity_type", "direction", "symmetric", "description") VALUES ('associated_with_pathogenesis', 'Pathway', 'Disease', 'directed', 0, 'Pathway associated with disease pathogenesis or progression.');
INSERT INTO "ontology_relations" ("relation_type", "source_entity_type", "target_entity_type", "direction", "symmetric", "description") VALUES ('involved_in_pathway', 'Metabolite', 'Pathway', 'directed', 0, 'Metabolite involved in biological or metabolic pathways.');
INSERT INTO "ontology_relations" ("relation_type", "source_entity_type", "target_entity_type", "direction", "symmetric", "description") VALUES ('associated_with_metabolic_change', 'Metabolite', 'Disease', 'directed', 0, 'Metabolite associated with disease-related metabolic changes.');
INSERT INTO "ontology_relations" ("relation_type", "source_entity_type", "target_entity_type", "direction", "symmetric", "description") VALUES ('subpathway_of', 'Pathway', 'Pathway', 'directed', 0, 'Hierarchical relationship between pathways or subpathways.');
INSERT INTO "ontology_relations" ("relation_type", "source_entity_type", "target_entity_type", "direction", "symmetric", "description") VALUES ('expressed_in_tissue', 'Protein', 'Tissue', 'directed', 0, 'Protein expression in a specific tissue.');
INSERT INTO "ontology_relations" ("relation_type", "source_entity_type", "target_entity_type", "direction", "symmetric", "description") VALUES ('expressed_in_celltype', 'Protein', 'CellType', 'directed', 0, 'Protein expression in a specific cell type.');
INSERT INTO "ontology_relations" ("relation_type", "source_entity_type", "target_entity_type", "direction", "symmetric", "description") VALUES ('located_in', 'CellType', 'Tissue', 'directed', 0, 'Cell type located in or associated with a specific tissue.');
INSERT INTO "ontology_relations" ("relation_type", "source_entity_type", "target_entity_type", "direction", "symmetric", "description") VALUES ('involved_in_disease', 'CellType', 'Disease', 'directed', 0, 'Cell type involved in disease occurrence, progression, or pathological change.');

INSERT INTO "ontology_use_cases" ("position", "use_case") VALUES (1, 'multi-source biomedical data integration');
INSERT INTO "ontology_use_cases" ("position", "use_case") VALUES (2, 'stage-aware knowledge graph construction');
INSERT INTO "ontology_use_cases" ("position", "use_case") VALUES (3, 'literature-derived knowledge extraction');
INSERT INTO "ontology_use_cases" ("position", "use_case") VALUES (4, 'evidence tracking and candidate knowledge validation');
INSERT INTO "ontology_use_cases" ("position", "use_case") VALUES (5, 'graph representation learning and link prediction');

INSERT INTO "progresses_to_relations" ("id", "disease_id", "disease_id_2", "relationship_type", "evidence_level", "source", "publication_id", "evidence_text", "date", "stage_order_delta", "validation_status", "notes", "created_at", "updated_at") VALUES (1, 'LD_STAGE_00', 'LD_STAGE_01', 'progresses_to', 'curated_database', 'project-defined progression model', NULL, NULL, NULL, NULL, 'accepted', NULL, NULL, NULL);
INSERT INTO "progresses_to_relations" ("id", "disease_id", "disease_id_2", "relationship_type", "evidence_level", "source", "publication_id", "evidence_text", "date", "stage_order_delta", "validation_status", "notes", "created_at", "updated_at") VALUES (2, 'LD_STAGE_01', 'LD_STAGE_02', 'progresses_to', 'curated_database', 'project-defined progression model', NULL, NULL, NULL, NULL, 'accepted', NULL, NULL, NULL);
INSERT INTO "progresses_to_relations" ("id", "disease_id", "disease_id_2", "relationship_type", "evidence_level", "source", "publication_id", "evidence_text", "date", "stage_order_delta", "validation_status", "notes", "created_at", "updated_at") VALUES (3, 'LD_STAGE_02', 'LD_STAGE_03', 'progresses_to', 'curated_database', 'project-defined progression model', NULL, NULL, NULL, NULL, 'accepted', NULL, NULL, NULL);
INSERT INTO "progresses_to_relations" ("id", "disease_id", "disease_id_2", "relationship_type", "evidence_level", "source", "publication_id", "evidence_text", "date", "stage_order_delta", "validation_status", "notes", "created_at", "updated_at") VALUES (4, 'LD_STAGE_03', 'LD_STAGE_04', 'progresses_to', 'curated_database', 'project-defined progression model', NULL, NULL, NULL, NULL, 'accepted', NULL, NULL, NULL);
INSERT INTO "progresses_to_relations" ("id", "disease_id", "disease_id_2", "relationship_type", "evidence_level", "source", "publication_id", "evidence_text", "date", "stage_order_delta", "validation_status", "notes", "created_at", "updated_at") VALUES (5, 'LD_STAGE_04', 'LD_STAGE_05', 'progresses_to', 'curated_database', 'project-defined progression model', NULL, NULL, NULL, NULL, 'accepted', NULL, NULL, NULL);

INSERT INTO "relation_allowed_sources" ("relation_type", "position", "allowed_source") VALUES ('associated_with', 1, 'DisGeNET');
INSERT INTO "relation_allowed_sources" ("relation_type", "position", "allowed_source") VALUES ('associated_with', 2, 'PubMed');
INSERT INTO "relation_allowed_sources" ("relation_type", "position", "allowed_source") VALUES ('associated_with', 3, 'LLM extraction');
INSERT INTO "relation_allowed_sources" ("relation_type", "position", "allowed_source") VALUES ('associated_with', 4, 'graph learning prediction');
INSERT INTO "relation_allowed_sources" ("relation_type", "position", "allowed_source") VALUES ('progresses_to', 1, 'project-defined progression model');
INSERT INTO "relation_allowed_sources" ("relation_type", "position", "allowed_source") VALUES ('progresses_to', 2, 'clinical guideline');
INSERT INTO "relation_allowed_sources" ("relation_type", "position", "allowed_source") VALUES ('progresses_to', 3, 'PubMed');
INSERT INTO "relation_allowed_sources" ("relation_type", "position", "allowed_source") VALUES ('encodes', 1, 'UniProt');
INSERT INTO "relation_allowed_sources" ("relation_type", "position", "allowed_source") VALUES ('encodes', 2, 'NCBI Gene');
INSERT INTO "relation_allowed_sources" ("relation_type", "position", "allowed_source") VALUES ('encodes', 3, 'HGNC');
INSERT INTO "relation_allowed_sources" ("relation_type", "position", "allowed_source") VALUES ('interacts_with', 1, 'STRING');
INSERT INTO "relation_allowed_sources" ("relation_type", "position", "allowed_source") VALUES ('interacts_with', 2, 'PubMed');
INSERT INTO "relation_allowed_sources" ("relation_type", "position", "allowed_source") VALUES ('interacts_with', 3, 'LLM extraction');
INSERT INTO "relation_allowed_sources" ("relation_type", "position", "allowed_source") VALUES ('interacts_with', 4, 'graph learning prediction');
INSERT INTO "relation_allowed_sources" ("relation_type", "position", "allowed_source") VALUES ('participates_in', 1, 'KEGG');
INSERT INTO "relation_allowed_sources" ("relation_type", "position", "allowed_source") VALUES ('participates_in', 2, 'Reactome');
INSERT INTO "relation_allowed_sources" ("relation_type", "position", "allowed_source") VALUES ('participates_in', 3, 'PubMed');
INSERT INTO "relation_allowed_sources" ("relation_type", "position", "allowed_source") VALUES ('participates_in', 4, 'LLM extraction');
INSERT INTO "relation_allowed_sources" ("relation_type", "position", "allowed_source") VALUES ('involved_in', 1, 'KEGG');
INSERT INTO "relation_allowed_sources" ("relation_type", "position", "allowed_source") VALUES ('involved_in', 2, 'Reactome');
INSERT INTO "relation_allowed_sources" ("relation_type", "position", "allowed_source") VALUES ('involved_in', 3, 'UniProt');
INSERT INTO "relation_allowed_sources" ("relation_type", "position", "allowed_source") VALUES ('involved_in', 4, 'PubMed');
INSERT INTO "relation_allowed_sources" ("relation_type", "position", "allowed_source") VALUES ('involved_in', 5, 'LLM extraction');
INSERT INTO "relation_allowed_sources" ("relation_type", "position", "allowed_source") VALUES ('associated_with_pathogenesis', 1, 'PubMed');
INSERT INTO "relation_allowed_sources" ("relation_type", "position", "allowed_source") VALUES ('associated_with_pathogenesis', 2, 'KEGG');
INSERT INTO "relation_allowed_sources" ("relation_type", "position", "allowed_source") VALUES ('associated_with_pathogenesis', 3, 'Reactome');
INSERT INTO "relation_allowed_sources" ("relation_type", "position", "allowed_source") VALUES ('associated_with_pathogenesis', 4, 'LLM extraction');
INSERT INTO "relation_allowed_sources" ("relation_type", "position", "allowed_source") VALUES ('associated_with_pathogenesis', 5, 'graph learning prediction');
INSERT INTO "relation_allowed_sources" ("relation_type", "position", "allowed_source") VALUES ('involved_in_pathway', 1, 'HMDB');
INSERT INTO "relation_allowed_sources" ("relation_type", "position", "allowed_source") VALUES ('involved_in_pathway', 2, 'KEGG');
INSERT INTO "relation_allowed_sources" ("relation_type", "position", "allowed_source") VALUES ('involved_in_pathway', 3, 'Reactome');
INSERT INTO "relation_allowed_sources" ("relation_type", "position", "allowed_source") VALUES ('involved_in_pathway', 4, 'PubMed');
INSERT INTO "relation_allowed_sources" ("relation_type", "position", "allowed_source") VALUES ('involved_in_pathway', 5, 'LLM extraction');
INSERT INTO "relation_allowed_sources" ("relation_type", "position", "allowed_source") VALUES ('associated_with_metabolic_change', 1, 'HMDB');
INSERT INTO "relation_allowed_sources" ("relation_type", "position", "allowed_source") VALUES ('associated_with_metabolic_change', 2, 'PubMed');
INSERT INTO "relation_allowed_sources" ("relation_type", "position", "allowed_source") VALUES ('associated_with_metabolic_change', 3, 'LLM extraction');
INSERT INTO "relation_allowed_sources" ("relation_type", "position", "allowed_source") VALUES ('associated_with_metabolic_change', 4, 'graph learning prediction');
INSERT INTO "relation_allowed_sources" ("relation_type", "position", "allowed_source") VALUES ('subpathway_of', 1, 'Reactome');
INSERT INTO "relation_allowed_sources" ("relation_type", "position", "allowed_source") VALUES ('subpathway_of', 2, 'KEGG');
INSERT INTO "relation_allowed_sources" ("relation_type", "position", "allowed_source") VALUES ('expressed_in_tissue', 1, 'Human Protein Atlas');
INSERT INTO "relation_allowed_sources" ("relation_type", "position", "allowed_source") VALUES ('expressed_in_celltype', 1, 'Human Protein Atlas');
INSERT INTO "relation_allowed_sources" ("relation_type", "position", "allowed_source") VALUES ('located_in', 1, 'Human Protein Atlas');
INSERT INTO "relation_allowed_sources" ("relation_type", "position", "allowed_source") VALUES ('located_in', 2, 'Cell Ontology');
INSERT INTO "relation_allowed_sources" ("relation_type", "position", "allowed_source") VALUES ('located_in', 3, 'Uberon');
INSERT INTO "relation_allowed_sources" ("relation_type", "position", "allowed_source") VALUES ('involved_in_disease', 1, 'PubMed');
INSERT INTO "relation_allowed_sources" ("relation_type", "position", "allowed_source") VALUES ('involved_in_disease', 2, 'Human Protein Atlas');
INSERT INTO "relation_allowed_sources" ("relation_type", "position", "allowed_source") VALUES ('involved_in_disease', 3, 'LLM extraction');

INSERT INTO "relation_attributes" ("relation_type", "attribute_group", "position", "attribute_name") VALUES ('associated_with', 'confirmed', 1, 'association_type');
INSERT INTO "relation_attributes" ("relation_type", "attribute_group", "position", "attribute_name") VALUES ('associated_with', 'confirmed', 2, 'score');
INSERT INTO "relation_attributes" ("relation_type", "attribute_group", "position", "attribute_name") VALUES ('associated_with', 'confirmed', 3, 'evidence_level');
INSERT INTO "relation_attributes" ("relation_type", "attribute_group", "position", "attribute_name") VALUES ('associated_with', 'confirmed', 4, 'source');
INSERT INTO "relation_attributes" ("relation_type", "attribute_group", "position", "attribute_name") VALUES ('associated_with', 'confirmed', 5, 'publication_id');
INSERT INTO "relation_attributes" ("relation_type", "attribute_group", "position", "attribute_name") VALUES ('associated_with', 'confirmed', 6, 'evidence_text');
INSERT INTO "relation_attributes" ("relation_type", "attribute_group", "position", "attribute_name") VALUES ('associated_with', 'confirmed', 7, 'date');
INSERT INTO "relation_attributes" ("relation_type", "attribute_group", "position", "attribute_name") VALUES ('associated_with', 'recommended', 1, 'source_record_id');
INSERT INTO "relation_attributes" ("relation_type", "attribute_group", "position", "attribute_name") VALUES ('associated_with', 'recommended', 2, 'validation_status');
INSERT INTO "relation_attributes" ("relation_type", "attribute_group", "position", "attribute_name") VALUES ('associated_with', 'recommended', 3, 'extraction_method');
INSERT INTO "relation_attributes" ("relation_type", "attribute_group", "position", "attribute_name") VALUES ('associated_with', 'recommended', 4, 'confidence_score');
INSERT INTO "relation_attributes" ("relation_type", "attribute_group", "position", "attribute_name") VALUES ('associated_with', 'planned', 1, 'notes');
INSERT INTO "relation_attributes" ("relation_type", "attribute_group", "position", "attribute_name") VALUES ('progresses_to', 'confirmed', 1, 'relationship_type');
INSERT INTO "relation_attributes" ("relation_type", "attribute_group", "position", "attribute_name") VALUES ('progresses_to', 'confirmed', 2, 'evidence_level');
INSERT INTO "relation_attributes" ("relation_type", "attribute_group", "position", "attribute_name") VALUES ('progresses_to', 'confirmed', 3, 'source');
INSERT INTO "relation_attributes" ("relation_type", "attribute_group", "position", "attribute_name") VALUES ('progresses_to', 'confirmed', 4, 'publication_id');
INSERT INTO "relation_attributes" ("relation_type", "attribute_group", "position", "attribute_name") VALUES ('progresses_to', 'confirmed', 5, 'evidence_text');
INSERT INTO "relation_attributes" ("relation_type", "attribute_group", "position", "attribute_name") VALUES ('progresses_to', 'confirmed', 6, 'date');
INSERT INTO "relation_attributes" ("relation_type", "attribute_group", "position", "attribute_name") VALUES ('progresses_to', 'recommended', 1, 'stage_order_delta');
INSERT INTO "relation_attributes" ("relation_type", "attribute_group", "position", "attribute_name") VALUES ('progresses_to', 'recommended', 2, 'validation_status');
INSERT INTO "relation_attributes" ("relation_type", "attribute_group", "position", "attribute_name") VALUES ('progresses_to', 'planned', 1, 'notes');
INSERT INTO "relation_attributes" ("relation_type", "attribute_group", "position", "attribute_name") VALUES ('encodes', 'confirmed', 1, 'source');
INSERT INTO "relation_attributes" ("relation_type", "attribute_group", "position", "attribute_name") VALUES ('encodes', 'confirmed', 2, 'evidence_level');
INSERT INTO "relation_attributes" ("relation_type", "attribute_group", "position", "attribute_name") VALUES ('encodes', 'confirmed', 3, 'date');
INSERT INTO "relation_attributes" ("relation_type", "attribute_group", "position", "attribute_name") VALUES ('encodes', 'recommended', 1, 'source_record_id');
INSERT INTO "relation_attributes" ("relation_type", "attribute_group", "position", "attribute_name") VALUES ('encodes', 'recommended', 2, 'validation_status');
INSERT INTO "relation_attributes" ("relation_type", "attribute_group", "position", "attribute_name") VALUES ('encodes', 'planned', 1, 'notes');
INSERT INTO "relation_attributes" ("relation_type", "attribute_group", "position", "attribute_name") VALUES ('interacts_with', 'confirmed', 1, 'combined_score');
INSERT INTO "relation_attributes" ("relation_type", "attribute_group", "position", "attribute_name") VALUES ('interacts_with', 'confirmed', 2, 'experimental_score');
INSERT INTO "relation_attributes" ("relation_type", "attribute_group", "position", "attribute_name") VALUES ('interacts_with', 'confirmed', 3, 'database_score');
INSERT INTO "relation_attributes" ("relation_type", "attribute_group", "position", "attribute_name") VALUES ('interacts_with', 'confirmed', 4, 'textmining_score');
INSERT INTO "relation_attributes" ("relation_type", "attribute_group", "position", "attribute_name") VALUES ('interacts_with', 'confirmed', 5, 'coexpression_score');
INSERT INTO "relation_attributes" ("relation_type", "attribute_group", "position", "attribute_name") VALUES ('interacts_with', 'confirmed', 6, 'source');
INSERT INTO "relation_attributes" ("relation_type", "attribute_group", "position", "attribute_name") VALUES ('interacts_with', 'confirmed', 7, 'date');
INSERT INTO "relation_attributes" ("relation_type", "attribute_group", "position", "attribute_name") VALUES ('interacts_with', 'recommended', 1, 'evidence_level');
INSERT INTO "relation_attributes" ("relation_type", "attribute_group", "position", "attribute_name") VALUES ('interacts_with', 'recommended', 2, 'source_record_id');
INSERT INTO "relation_attributes" ("relation_type", "attribute_group", "position", "attribute_name") VALUES ('interacts_with', 'recommended', 3, 'validation_status');
INSERT INTO "relation_attributes" ("relation_type", "attribute_group", "position", "attribute_name") VALUES ('interacts_with', 'planned', 1, 'notes');
INSERT INTO "relation_attributes" ("relation_type", "attribute_group", "position", "attribute_name") VALUES ('participates_in', 'confirmed', 1, 'role');
INSERT INTO "relation_attributes" ("relation_type", "attribute_group", "position", "attribute_name") VALUES ('participates_in', 'confirmed', 2, 'source');
INSERT INTO "relation_attributes" ("relation_type", "attribute_group", "position", "attribute_name") VALUES ('participates_in', 'confirmed', 3, 'evidence_level');
INSERT INTO "relation_attributes" ("relation_type", "attribute_group", "position", "attribute_name") VALUES ('participates_in', 'confirmed', 4, 'date');
INSERT INTO "relation_attributes" ("relation_type", "attribute_group", "position", "attribute_name") VALUES ('participates_in', 'recommended', 1, 'source_record_id');
INSERT INTO "relation_attributes" ("relation_type", "attribute_group", "position", "attribute_name") VALUES ('participates_in', 'recommended', 2, 'validation_status');
INSERT INTO "relation_attributes" ("relation_type", "attribute_group", "position", "attribute_name") VALUES ('participates_in', 'planned', 1, 'notes');
INSERT INTO "relation_attributes" ("relation_type", "attribute_group", "position", "attribute_name") VALUES ('involved_in', 'confirmed', 1, 'role');
INSERT INTO "relation_attributes" ("relation_type", "attribute_group", "position", "attribute_name") VALUES ('involved_in', 'confirmed', 2, 'source');
INSERT INTO "relation_attributes" ("relation_type", "attribute_group", "position", "attribute_name") VALUES ('involved_in', 'confirmed', 3, 'evidence_level');
INSERT INTO "relation_attributes" ("relation_type", "attribute_group", "position", "attribute_name") VALUES ('involved_in', 'confirmed', 4, 'date');
INSERT INTO "relation_attributes" ("relation_type", "attribute_group", "position", "attribute_name") VALUES ('involved_in', 'recommended', 1, 'source_record_id');
INSERT INTO "relation_attributes" ("relation_type", "attribute_group", "position", "attribute_name") VALUES ('involved_in', 'recommended', 2, 'validation_status');
INSERT INTO "relation_attributes" ("relation_type", "attribute_group", "position", "attribute_name") VALUES ('involved_in', 'planned', 1, 'notes');
INSERT INTO "relation_attributes" ("relation_type", "attribute_group", "position", "attribute_name") VALUES ('associated_with_pathogenesis', 'confirmed', 1, 'evidence_level');
INSERT INTO "relation_attributes" ("relation_type", "attribute_group", "position", "attribute_name") VALUES ('associated_with_pathogenesis', 'confirmed', 2, 'source');
INSERT INTO "relation_attributes" ("relation_type", "attribute_group", "position", "attribute_name") VALUES ('associated_with_pathogenesis', 'confirmed', 3, 'publication_id');
INSERT INTO "relation_attributes" ("relation_type", "attribute_group", "position", "attribute_name") VALUES ('associated_with_pathogenesis', 'confirmed', 4, 'evidence_text');
INSERT INTO "relation_attributes" ("relation_type", "attribute_group", "position", "attribute_name") VALUES ('associated_with_pathogenesis', 'confirmed', 5, 'date');
INSERT INTO "relation_attributes" ("relation_type", "attribute_group", "position", "attribute_name") VALUES ('associated_with_pathogenesis', 'recommended', 1, 'mechanism_description');
INSERT INTO "relation_attributes" ("relation_type", "attribute_group", "position", "attribute_name") VALUES ('associated_with_pathogenesis', 'recommended', 2, 'validation_status');
INSERT INTO "relation_attributes" ("relation_type", "attribute_group", "position", "attribute_name") VALUES ('associated_with_pathogenesis', 'recommended', 3, 'extraction_method');
INSERT INTO "relation_attributes" ("relation_type", "attribute_group", "position", "attribute_name") VALUES ('associated_with_pathogenesis', 'recommended', 4, 'confidence_score');
INSERT INTO "relation_attributes" ("relation_type", "attribute_group", "position", "attribute_name") VALUES ('associated_with_pathogenesis', 'planned', 1, 'notes');
INSERT INTO "relation_attributes" ("relation_type", "attribute_group", "position", "attribute_name") VALUES ('involved_in_pathway', 'confirmed', 1, 'role');
INSERT INTO "relation_attributes" ("relation_type", "attribute_group", "position", "attribute_name") VALUES ('involved_in_pathway', 'confirmed', 2, 'source');
INSERT INTO "relation_attributes" ("relation_type", "attribute_group", "position", "attribute_name") VALUES ('involved_in_pathway', 'confirmed', 3, 'evidence_level');
INSERT INTO "relation_attributes" ("relation_type", "attribute_group", "position", "attribute_name") VALUES ('involved_in_pathway', 'confirmed', 4, 'date');
INSERT INTO "relation_attributes" ("relation_type", "attribute_group", "position", "attribute_name") VALUES ('involved_in_pathway', 'recommended', 1, 'source_record_id');
INSERT INTO "relation_attributes" ("relation_type", "attribute_group", "position", "attribute_name") VALUES ('involved_in_pathway', 'recommended', 2, 'validation_status');
INSERT INTO "relation_attributes" ("relation_type", "attribute_group", "position", "attribute_name") VALUES ('involved_in_pathway', 'planned', 1, 'notes');
INSERT INTO "relation_attributes" ("relation_type", "attribute_group", "position", "attribute_name") VALUES ('associated_with_metabolic_change', 'confirmed', 1, 'change_direction');
INSERT INTO "relation_attributes" ("relation_type", "attribute_group", "position", "attribute_name") VALUES ('associated_with_metabolic_change', 'confirmed', 2, 'evidence_level');
INSERT INTO "relation_attributes" ("relation_type", "attribute_group", "position", "attribute_name") VALUES ('associated_with_metabolic_change', 'confirmed', 3, 'source');
INSERT INTO "relation_attributes" ("relation_type", "attribute_group", "position", "attribute_name") VALUES ('associated_with_metabolic_change', 'confirmed', 4, 'publication_id');
INSERT INTO "relation_attributes" ("relation_type", "attribute_group", "position", "attribute_name") VALUES ('associated_with_metabolic_change', 'confirmed', 5, 'evidence_text');
INSERT INTO "relation_attributes" ("relation_type", "attribute_group", "position", "attribute_name") VALUES ('associated_with_metabolic_change', 'confirmed', 6, 'date');
INSERT INTO "relation_attributes" ("relation_type", "attribute_group", "position", "attribute_name") VALUES ('associated_with_metabolic_change', 'recommended', 1, 'sample_type');
INSERT INTO "relation_attributes" ("relation_type", "attribute_group", "position", "attribute_name") VALUES ('associated_with_metabolic_change', 'recommended', 2, 'concentration');
INSERT INTO "relation_attributes" ("relation_type", "attribute_group", "position", "attribute_name") VALUES ('associated_with_metabolic_change', 'recommended', 3, 'validation_status');
INSERT INTO "relation_attributes" ("relation_type", "attribute_group", "position", "attribute_name") VALUES ('associated_with_metabolic_change', 'recommended', 4, 'extraction_method');
INSERT INTO "relation_attributes" ("relation_type", "attribute_group", "position", "attribute_name") VALUES ('associated_with_metabolic_change', 'recommended', 5, 'confidence_score');
INSERT INTO "relation_attributes" ("relation_type", "attribute_group", "position", "attribute_name") VALUES ('associated_with_metabolic_change', 'planned', 1, 'notes');
INSERT INTO "relation_attributes" ("relation_type", "attribute_group", "position", "attribute_name") VALUES ('subpathway_of', 'confirmed', 1, 'source');
INSERT INTO "relation_attributes" ("relation_type", "attribute_group", "position", "attribute_name") VALUES ('subpathway_of', 'confirmed', 2, 'evidence_level');
INSERT INTO "relation_attributes" ("relation_type", "attribute_group", "position", "attribute_name") VALUES ('subpathway_of', 'confirmed', 3, 'date');
INSERT INTO "relation_attributes" ("relation_type", "attribute_group", "position", "attribute_name") VALUES ('subpathway_of', 'recommended', 1, 'source_record_id');
INSERT INTO "relation_attributes" ("relation_type", "attribute_group", "position", "attribute_name") VALUES ('subpathway_of', 'recommended', 2, 'validation_status');
INSERT INTO "relation_attributes" ("relation_type", "attribute_group", "position", "attribute_name") VALUES ('subpathway_of', 'planned', 1, 'notes');
INSERT INTO "relation_attributes" ("relation_type", "attribute_group", "position", "attribute_name") VALUES ('expressed_in_tissue', 'confirmed', 1, 'expression_level');
INSERT INTO "relation_attributes" ("relation_type", "attribute_group", "position", "attribute_name") VALUES ('expressed_in_tissue', 'confirmed', 2, 'source');
INSERT INTO "relation_attributes" ("relation_type", "attribute_group", "position", "attribute_name") VALUES ('expressed_in_tissue', 'confirmed', 3, 'date');
INSERT INTO "relation_attributes" ("relation_type", "attribute_group", "position", "attribute_name") VALUES ('expressed_in_tissue', 'recommended', 1, 'expression_score');
INSERT INTO "relation_attributes" ("relation_type", "attribute_group", "position", "attribute_name") VALUES ('expressed_in_tissue', 'recommended', 2, 'evidence_level');
INSERT INTO "relation_attributes" ("relation_type", "attribute_group", "position", "attribute_name") VALUES ('expressed_in_tissue', 'recommended', 3, 'source_record_id');
INSERT INTO "relation_attributes" ("relation_type", "attribute_group", "position", "attribute_name") VALUES ('expressed_in_tissue', 'recommended', 4, 'validation_status');
INSERT INTO "relation_attributes" ("relation_type", "attribute_group", "position", "attribute_name") VALUES ('expressed_in_tissue', 'planned', 1, 'notes');
INSERT INTO "relation_attributes" ("relation_type", "attribute_group", "position", "attribute_name") VALUES ('expressed_in_celltype', 'confirmed', 1, 'expression_level');
INSERT INTO "relation_attributes" ("relation_type", "attribute_group", "position", "attribute_name") VALUES ('expressed_in_celltype', 'confirmed', 2, 'source');
INSERT INTO "relation_attributes" ("relation_type", "attribute_group", "position", "attribute_name") VALUES ('expressed_in_celltype', 'confirmed', 3, 'date');
INSERT INTO "relation_attributes" ("relation_type", "attribute_group", "position", "attribute_name") VALUES ('expressed_in_celltype', 'recommended', 1, 'expression_score');
INSERT INTO "relation_attributes" ("relation_type", "attribute_group", "position", "attribute_name") VALUES ('expressed_in_celltype', 'recommended', 2, 'evidence_level');
INSERT INTO "relation_attributes" ("relation_type", "attribute_group", "position", "attribute_name") VALUES ('expressed_in_celltype', 'recommended', 3, 'source_record_id');
INSERT INTO "relation_attributes" ("relation_type", "attribute_group", "position", "attribute_name") VALUES ('expressed_in_celltype', 'recommended', 4, 'validation_status');
INSERT INTO "relation_attributes" ("relation_type", "attribute_group", "position", "attribute_name") VALUES ('expressed_in_celltype', 'planned', 1, 'notes');
INSERT INTO "relation_attributes" ("relation_type", "attribute_group", "position", "attribute_name") VALUES ('located_in', 'confirmed', 1, 'source');
INSERT INTO "relation_attributes" ("relation_type", "attribute_group", "position", "attribute_name") VALUES ('located_in', 'confirmed', 2, 'evidence_level');
INSERT INTO "relation_attributes" ("relation_type", "attribute_group", "position", "attribute_name") VALUES ('located_in', 'recommended', 1, 'date');
INSERT INTO "relation_attributes" ("relation_type", "attribute_group", "position", "attribute_name") VALUES ('located_in', 'recommended', 2, 'source_record_id');
INSERT INTO "relation_attributes" ("relation_type", "attribute_group", "position", "attribute_name") VALUES ('located_in', 'recommended', 3, 'validation_status');
INSERT INTO "relation_attributes" ("relation_type", "attribute_group", "position", "attribute_name") VALUES ('located_in', 'planned', 1, 'notes');
INSERT INTO "relation_attributes" ("relation_type", "attribute_group", "position", "attribute_name") VALUES ('involved_in_disease', 'confirmed', 1, 'role');
INSERT INTO "relation_attributes" ("relation_type", "attribute_group", "position", "attribute_name") VALUES ('involved_in_disease', 'confirmed', 2, 'source');
INSERT INTO "relation_attributes" ("relation_type", "attribute_group", "position", "attribute_name") VALUES ('involved_in_disease', 'confirmed', 3, 'evidence_level');
INSERT INTO "relation_attributes" ("relation_type", "attribute_group", "position", "attribute_name") VALUES ('involved_in_disease', 'confirmed', 4, 'publication_id');
INSERT INTO "relation_attributes" ("relation_type", "attribute_group", "position", "attribute_name") VALUES ('involved_in_disease', 'confirmed', 5, 'evidence_text');
INSERT INTO "relation_attributes" ("relation_type", "attribute_group", "position", "attribute_name") VALUES ('involved_in_disease', 'confirmed', 6, 'date');
INSERT INTO "relation_attributes" ("relation_type", "attribute_group", "position", "attribute_name") VALUES ('involved_in_disease', 'recommended', 1, 'validation_status');
INSERT INTO "relation_attributes" ("relation_type", "attribute_group", "position", "attribute_name") VALUES ('involved_in_disease', 'recommended', 2, 'extraction_method');
INSERT INTO "relation_attributes" ("relation_type", "attribute_group", "position", "attribute_name") VALUES ('involved_in_disease', 'recommended', 3, 'confidence_score');
INSERT INTO "relation_attributes" ("relation_type", "attribute_group", "position", "attribute_name") VALUES ('involved_in_disease', 'planned', 1, 'notes');

INSERT INTO "relation_provenance_fields" ("field_group", "position", "field_name") VALUES ('required', 1, 'source');
INSERT INTO "relation_provenance_fields" ("field_group", "position", "field_name") VALUES ('required', 2, 'evidence_level');
INSERT INTO "relation_provenance_fields" ("field_group", "position", "field_name") VALUES ('required', 3, 'date');
INSERT INTO "relation_provenance_fields" ("field_group", "position", "field_name") VALUES ('recommended', 1, 'publication_id');
INSERT INTO "relation_provenance_fields" ("field_group", "position", "field_name") VALUES ('recommended', 2, 'evidence_text');
INSERT INTO "relation_provenance_fields" ("field_group", "position", "field_name") VALUES ('recommended', 3, 'source_record_id');
INSERT INTO "relation_provenance_fields" ("field_group", "position", "field_name") VALUES ('recommended', 4, 'extraction_method');
INSERT INTO "relation_provenance_fields" ("field_group", "position", "field_name") VALUES ('recommended', 5, 'confidence_score');
INSERT INTO "relation_provenance_fields" ("field_group", "position", "field_name") VALUES ('recommended', 6, 'validation_status');
INSERT INTO "relation_provenance_fields" ("field_group", "position", "field_name") VALUES ('recommended', 7, 'validated_by');
INSERT INTO "relation_provenance_fields" ("field_group", "position", "field_name") VALUES ('recommended', 8, 'notes');

INSERT INTO "validation_status_values" ("position", "status_value") VALUES (1, 'imported');
INSERT INTO "validation_status_values" ("position", "status_value") VALUES (2, 'candidate');
INSERT INTO "validation_status_values" ("position", "status_value") VALUES (3, 'reviewed');
INSERT INTO "validation_status_values" ("position", "status_value") VALUES (4, 'accepted');
INSERT INTO "validation_status_values" ("position", "status_value") VALUES (5, 'rejected');
