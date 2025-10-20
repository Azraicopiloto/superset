#!/bin/bash
set -e

echo "🚀 Starting Superset setup..."

if [[ "$FORCE_RESET" == "1" ]]; then
  echo "⚠️ FORCE_RESET detected — dropping and recreating schema..."
  PSQL_COMPATIBLE_URL="${DATABASE_URL/+psycopg2/}"
  psql "$PSQL_COMPATIBLE_URL" -c "DROP SCHEMA public CASCADE; CREATE SCHEMA public;"
  echo "✅ Schema reset successfully."
fi

echo "🧩 Running migrations..."
superset db upgrade

echo "👤 Ensuring admin user exists..."
superset fab create-admin \
  --username admin \
  --firstname Superset \
  --lastname Admin \
  --email admin@example.com \
  --password admin || true

echo "✨ Initializing Superset roles and permissions..."
superset init

# ⚠️ Skip loading example data (uses too much memory)
echo "⏭️ Skipping example dataset load to save memory..."

echo "🌐 Starting Superset on port ${PORT:-8088}"
exec gunicorn --bind "0.0.0.0:${PORT:-8088}" --workers 2 --timeout 300 "superset.app:create_app()"
