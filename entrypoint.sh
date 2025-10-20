#!/bin/bash
set -e

echo "⚠️ FORCE_RESET detected — dropping and recreating schema..."

# Your app's DATABASE_URL might be like: postgresql+psycopg2://user:pass@host/db
# We need to remove the "+psycopg2" part for psql to use it.
PSQL_URL="${DATABASE_URL/+psycopg2/}"

# Now, execute the command using the full URI.
# The quotes are crucial to handle special characters in the password.
psql "$PSQL_URL" -c "DROP SCHEMA public CASCADE; CREATE SCHEMA public;"

echo "✅ Schema reset successfully."

# ...continue with the rest of your script (e.g., superset db upgrade)
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
