# -------------------------------------------------------
# Apache Superset with automatic schema reset capability
# -------------------------------------------------------

FROM apache/superset:3.1.2

USER root
WORKDIR /app

# Install PostgreSQL client for schema management
RUN apt-get update && \
    apt-get install -y --no-install-recommends libpq-dev gcc postgresql-client && \
    rm -rf /var/lib/apt/lists/*

# Copy custom Superset configuration
COPY superset_config.py /app/superset_config.py

# -------------------------
# Environment configuration
# -------------------------
ENV SUPERSET_HOME=/app/superset_home
ENV FLASK_DEBUG=0
ENV SUPERSET_PORT=8088
ENV SUPERSET_LOAD_EXAMPLES=no
ENV SUPERSET_CONFIG_PATH=/app/superset_config.py

EXPOSE 8088

# -------------------------------------------------------
# Startup sequence
# -------------------------------------------------------
CMD \
    # Extract connection components for psql from DATABASE_URL
    DB_URI=$(echo "$DATABASE_URL" | sed 's#postgresql+psycopg2://##') && \
    DB_USER=$(echo "$DB_URI" | cut -d':' -f1) && \
    DB_PASS=$(echo "$DB_URI" | cut -d':' -f2 | cut -d'@' -f1) && \
    DB_HOST=$(echo "$DB_URI" | cut -d'@' -f2 | cut -d':' -f1) && \
    DB_PORT=$(echo "$DB_URI" | cut -d':' -f3 | cut -d'/' -f1) && \
    DB_NAME=$(echo "$DB_URI" | awk -F'/' '{print $NF}') && \
    \
    # Optional reset
    if [ "$DB_RESET" = "1" ]; then \
      echo "⚠️  Resetting PostgreSQL schema on $DB_HOST:$DB_PORT/$DB_NAME..."; \
      PGPASSWORD="$DB_PASS" psql -h "$DB_HOST" -U "$DB_USER" -p "$DB_PORT" -d "$DB_NAME" \
        -c "DROP SCHEMA IF EXISTS public CASCADE; CREATE SCHEMA public;"; \
    fi && \
    \
    echo "🚀 Running DB migrations..." && \
    superset db upgrade && \
    echo "👤 Creating admin user..." && \
    superset fab create-admin \
        --username admin \
        --firstname Admin \
        --lastname User \
        --email admin@superset.com \
        --password admin \
        --role Admin --force && \
    echo "✨ Initializing Superset..." && \
    superset init && \
    echo "🌐 Starting Gunicorn..." && \
    gunicorn --bind 0.0.0.0:${PORT:-8088} "superset.app:create_app()"
