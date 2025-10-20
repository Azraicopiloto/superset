# ---------------------------
# Apache Superset with optional schema reset
# ---------------------------

FROM apache/superset:3.1.2

# Switch to root to install system packages
USER root

WORKDIR /app

# Install PostgreSQL client & required dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends libpq-dev gcc postgresql-client && \
    rm -rf /var/lib/apt/lists/*

# Copy Superset configuration file
COPY superset_config.py /app/superset_config.py

# ---------------------------
# Environment Variables
# ---------------------------
ENV SUPERSET_HOME=/app/superset_home
ENV FLASK_DEBUG=0
ENV SUPERSET_PORT=8088
ENV SUPERSET_LOAD_EXAMPLES=no
ENV SUPERSET_CONFIG_PATH=/app/superset_config.py

# ---------------------------
# Expose the web port
# ---------------------------
EXPOSE 8088

# ---------------------------
# Command: reset schema (optional), upgrade DB, create admin, start server
# ---------------------------
CMD if [ "$DB_RESET" = "1" ]; then \
  echo "⚠️  Resetting PostgreSQL public schema..."; \
  psql "$PSQL_URL" -c "DROP SCHEMA IF EXISTS public CASCADE; CREATE SCHEMA public;"; \
fi && \
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
