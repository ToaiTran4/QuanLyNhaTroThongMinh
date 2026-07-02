# Database Migrations

This directory contains database migration scripts for the QuanLyNhaTroThongMinh system.

## Migration Files

- `V1__init_schema.sql`: Initial database schema creation

## Running Migrations

### Manual Execution

Connect to your PostgreSQL database and execute the migration files in order:

```bash
psql -h <host> -p <port> -U <user> -d <database> -f V1__init_schema.sql
```

### Using Flyway (Recommended)

If using Flyway for migration management:

1. Install Flyway
2. Configure `flyway.conf` with your database credentials
3. Run:

```bash
flyway migrate
```

## Rollback

Currently, no rollback scripts are provided for the initial schema. For future migrations, we will include corresponding `U__` undo scripts.
