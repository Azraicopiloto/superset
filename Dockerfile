# -------------------------------------------------------
# Apache Superset - Stable + Auto Admin + Migration Fix
# -------------------------------------------------------

FROM apache/superset:3.1.2

USER root
WORKDIR /app

# Install PostgreSQL client (for schema & migration handling)
RUN apt-get update && \
    apt-get install -y --no-install-recommends libpq-dev gcc postgresql-client && \
    rm -rf /var/lib/apt/lists/*

# Copy your Superset configuration
COPY superset_config.py /app/superset_config.py

# Environment variables
ENV SUPERSET_HOME=/app/superset_home
ENV FLASK_DEBUG=0
ENV SUPERSET_PORT=8088
ENV SUPERSET_LOAD_EXAMPLES=no
ENV SUPERSET_CONFIG_PATH=/app/superset_config.py

EXPOSE 8088

# -------------------------------------------------------
# Startup logic with migration recovery
# -------------------------------------------------------
CMD set -e; \
    echo "🚀 Starting Superset setup..."; \
    \
    echo "🧩 Running initial DB migrations..."; \
    if ! superset db upgrade; then \
        echo "⚠️ Migration failed — resetting Alembic version table..."; \
        DB_URI=$(echo "$DATABASE_URL" | sed 's#postgresql+psycopg2://##'); \
        DB_USER=$(echo "$DB_URI" | cut -d':' -f1); \
        DB_PASS=$(echo "$DB_URI" | cut -d':' -f2 | cut -d'@' -f1); \
        DB_HOST=$(echo "$DB_URI" | cut -d'@' -f2 | cut -d':' -f1); \
        DB_PORT=$(echo "$DB_URI" | cut -d':' -f3 | cut -d'/' -f1); \
        DB_NAME=$(echo "$DB_URI" | awk -F'/' '{print $NF}'); \
        PGPASSWORD="$DB_PASS" psql -h "$DB_HOST" -U "$DB_USER" -p "$DB_PORT" -d "$DB_NAME" -c "DROP TABLE IF EXISTS alembic_version CASCADE;"; \
        superset db upgrade; \
    fi; \
    \
    echo "👤 Creating admin user if not exists..."; \
    superset fab create-admin \
        --username admin \
        --firstname Admin \
        --lastname User \
        --email admin@superset.com \
        --password admin --force || true; \
    \
    echo "✨ Initializing Superset..."; \
    superset init; \
    \
    echo "🌐 Launching Superset on port ${PORT:-8088}..."; \
    gunicorn --bind 0.0.0.0:${PORT:-8088} "superset.app:create_app()"
