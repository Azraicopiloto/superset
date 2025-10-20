#!/bin/bash
set -e

echo "🚀 Starting Superset setup..."

DB_URI=$(echo "$DATABASE_URL" | sed 's#postgresql+psycopg2://##')
DB_USER=$(echo "$DB_URI" | cut -d':' -f1)
DB_PASS=$(echo "$DB_URI" | cut -d':' -f2 | cut -d'@' -f1)
DB_HOST=$(echo "$DB_URI" | cut -d'@' -f2 | cut -d':' -f1)
DB_PORT=$(echo "$DB_URI" | cut -d':' -f3 | cut -d'/' -f1)
DB_NAME=$(echo "$DB_URI" | awk -F'/' '{print $NF}')

echo "🔧 Preparing temporary .pgpass file for secure PostgreSQL auth..."
echo "${DB_HOST}:${DB_PORT}:${DB_NAME}:${DB_USER}:${DB_PASS}" > ~/.pgpass
chmod 600 ~/.pgpass

# Optional full schema reset
if [ "$FORCE_RESET" = "1" ]; then
    echo "⚠️ FORCE_RESET detected — dropping and recreating schema..."
    psql -h "$DB_HOST" -U "$DB_USER" -p "$DB_PORT" -d "$DB_NAME" -c "DROP SCHEMA public CASCADE; CREATE SCHEMA public;"
fi

echo "🧩 Running initial DB migrations..."
if ! superset db upgrade; then
    echo "⚠️ Migration failed — resetting Alembic version table..."
    psql -h "$DB_HOST" -U "$DB_USER" -p "$DB_PORT" -d "$DB_NAME" -c "DROP TABLE IF EXISTS alembic_version CASCADE;"
    superset db upgrade
fi

rm -f ~/.pgpass

echo "👤 Creating admin user if not exists..."
superset fab create-admin \
    --username admin \
    --firstname Admin \
    --lastname User \
    --email admin@superset.com \
    --password admin --force || true

echo "✨ Initializing Superset..."
superset init

echo "🌐 Launching Superset on port ${PORT:-8088}..."
exec gunicorn --bind 0.0.0.0:${PORT:-8088} "superset.app:create_app()"
