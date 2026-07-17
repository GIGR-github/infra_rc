-- ==============================================================================
-- DATABASE BOOTSTRAP SCRIPT: IAM & RBAC Initialization Config (init.sql)
-- TARGET ENVIRONMENT:        UAT / Production (MySQL 8.4 Engine)
-- METADATA:                  Ticket:   [JIRA-4025] Database Infrastructure Hardening
--                            Date:     2026-05-03
--                            Author:   Pavel P. <ppanbeing@redcoast.com>
-- ==============================================================================
-- DESCRIPTION:
--   Initializes the core schema and enforces a zero-trust security topology
--   using Role-Based Access Control (RBAC) and Identity & Access Management (IAM).
--
-- SECURITY ARCHITECTURE & POLICIES ENFORCED:
--   1. Role-Based Access Control (RBAC):
--      - 'flyway_role': Full DDL/DML capabilities. Granted exclusively to the
--        migration service engine for schema mutations.
--      - 'app_role': Pure DML operational capabilities. Strictly blocks structural
--        database changes (DDL) at runtime.
--   2. Principle of Least Privilege (PoLP):
--      - Separation of Concerns: The application layer ('app_role') is completely
--        restricted from running dangerous commands like DROP, ALTER, or CREATE.
--   3. IAM Hardening & Connection Throttling:
--      - Migration Account: Capped at MAX_USER_CONNECTIONS 3 to eliminate connection
--        exhaustion risks during automated pipeline runouts.
--      - Password & Security Policies: Enforces production-grade account profiles:
--        * Password expiration intervals (180 days) and history reuse locks.
--        * Brute-force protection via anti-automation locks (3 failed attempts -> 1 day lock).
-- ==============================================================================
CREATE DATABASE IF NOT EXISTS `${MYSQL_DATABASE}`;
USE `${MYSQL_DATABASE}`;
-- RBAC Definition
CREATE ROLE IF NOT EXISTS 'flyway_role';
CREATE ROLE IF NOT EXISTS 'app_role';
-- Flyway Privileges: Full DDL/DML
GRANT ALTER, CREATE, DROP, INDEX, INSERT,
    SELECT, UPDATE, DELETE, REFERENCES
    ON `${MYSQL_DATABASE}`.* TO 'flyway_role';
-- Application Privileges: Strictly DML
-- Implements PoLP
GRANT SELECT, INSERT, UPDATE, DELETE, EXECUTE
    ON `${MYSQL_DATABASE}`.* TO 'app_role';
-- IAM: Migration Service
CREATE USER IF NOT EXISTS '${FLYWAY_USER}'@'%'
    IDENTIFIED BY '${FLYWAY_PASSWORD}'
    WITH MAX_USER_CONNECTIONS 3
    PASSWORD EXPIRE NEVER;
-- IAM: Application Service
CREATE USER IF NOT EXISTS '${DB_USERNAME}'@'%'
    IDENTIFIED BY '${DB_PASSWORD}'
    PASSWORD REUSE INTERVAL 90 DAY
    PASSWORD EXPIRE INTERVAL 180 DAY
    FAILED_LOGIN_ATTEMPTS 3 PASSWORD_LOCK_TIME 1
    PASSWORD HISTORY 4;
-- IAM: Role assignment and default activation
GRANT 'flyway_role' TO '${FLYWAY_USER}'@'%';
SET DEFAULT ROLE 'flyway_role' TO '${FLYWAY_USER}'@'%';
GRANT 'app_role' TO '${DB_USERNAME}'@'%';
SET DEFAULT ROLE 'app_role' TO '${DB_USERNAME}'@'%';
