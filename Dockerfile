FROM apache/superset:latest

# Switch to root for system installs
USER root

WORKDIR /app

# Install PostgreSQL libs and compiler
RUN apt-get update && apt-get install -y libpq-dev gcc curl && rm -rf /var/lib/apt/lists/*

# Install psycopg2 both globally and (if exists) inside Superset’s virtual environment
RUN pip install --no-cache-dir --upgrade pip psycopg2-binary && \
    if [ -d "/app/.venv/bin" ]; then /app/.venv/bin/pip install --no-cache-dir psycopg2-binary; fi

# Copy Superset config file
COPY superset_config.py /app/superset_config.py

# Environment variables
ENV SUPERSET_HOME=/app/superset_home
ENV FLASK_ENV=production
ENV SUPERSET_PORT=8088
ENV SUPERSET_LOAD_EXAMPLES=no
ENV SUPERSET_CONFIG_PATH=/app/superset_config.py

# Add a healthcheck so Render waits for the service to come online
HEALTHCHECK --interval=30s --timeout=10s --retries=5 CMD curl -f http://localhost:8088/health || exit 1

EXPOSE 8088

# Initialize and run Superset
CMD /app/.venv/bin/superset db upgrade && \
    /app/.venv/bin/superset init && \
    /app/.venv/bin/gunicorn --bind 0.0.0.0:8088 "superset.app:create_app()"
