-- Runs once, when the primary is first created (as the carebridge superuser).
-- 1) a special user that the replica uses to copy and follow the primary
CREATE ROLE replicator WITH REPLICATION LOGIN PASSWORD 'replpass';
-- 2) permission for that user to connect for replication (adds one line to pg_hba.conf)
COPY (SELECT 'host replication replicator all scram-sha-256') TO PROGRAM 'cat >> "$PGDATA/pg_hba.conf"';
