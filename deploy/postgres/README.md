# FYP Ontology PostgreSQL Docker

This folder runs the ontology database as a portable PostgreSQL container.

## Start

```powershell
copy .env.example .env
docker compose up -d
```

On first startup, PostgreSQL imports:

```text
init/02_schema_and_seed.sql
```

The persistent database files are stored in the Docker volume:

```text
fyp_ontology_pgdata
```

## Navicat Connection

Use a PostgreSQL connection:

```text
Host: localhost
Port: 5432
Database: fyp_ontology
User: postgres
Password: fyp_ontology_dev_password
Schema: ontology
```

Change `.env` before first startup if you want a different password or port.

## Reset And Reimport

This deletes the Docker volume and rebuilds the database from the SQL file:

```powershell
docker compose down -v
docker compose up -d
```
