#!/bin/bash
# Exit immediately if a command exits with a non-zero status
set -e

echo "🚀 Starting Superset setup..."

# Only run the reset logic if FORCE_RESET is set to '1'
if [[ "$FORCE_RESET" == "1" ]]; then
  echo "⚠️ FORCE_RESET detected — dropping and recreating schema..."

  # Superset's DATABASE_URL is like: postgresql+psycopg2://...
  # psql needs a standard URI like: postgresql://...
  # This command removes the '+psycopg2' part for psql compatibility.
  PSQL_COMPATIBLE_URL="${DATABASE_URL/+psycopg2/}"

  # Execute the schema reset using the compatible URL.
  # This single command is all that's needed for authentication.
  psql "$PSQL_COMPATIBLE_URL" -c "DROP SCHEMA public CASCADE; CREATE SCHEMA public;"
  
  echo "✅ Schema reset successfully."
fi

echo "🧩 Running migrations..."
superset db upgrade

echo "👤 Creating admin user..."
superset fab create-admin \
  --username admin \
  --firstname Superset \
  --lastname Admin \
  --email admin@example.com \
  --password admin

echo "✨ Initializing Superset..."
superset init

echo "🌐 Starting Superset on port ${PORT:-8088}"
# Use exec to replace the script process with the gunicorn process
exec gunicorn --bind "0.0.0.0:${PORT:-8088}" --workers 3 --timeout 120 "superset.app:create_app()"
