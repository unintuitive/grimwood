local migrations = require("lapis.db.migrations")
-- migrations.create_migrations_table()
migrations.run_migrations(require"migrations")
