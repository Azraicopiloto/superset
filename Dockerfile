FROM apache/superset:latest

USER root
WORKDIR /app

# Install system dependencies for psycopg2
RUN apt-get update && apt-get install -y libpq-dev gcc curl && rm -rf /var/lib/apt/lists/*

# Install psycopg2 INSIDE Superset's venv
RUN /app/.venv/bin/pip install --no-cache-dir --upgrade pip psycopg2-binary

# Copy Superset config
COPY superset_config.py /app/superset_config.py

# Environment variables
ENV SUPERSET_HOME=/app/superset_home
ENV FLASK_ENV=production
ENV SUPERSET_PORT=8088
ENV SUPERSET_LOAD_EXAMPLES=no
ENV SUPERSET_CONFIG_PATH=/app/superset_config.py

EXPOSE 8088

# Health check for Render
HEALTHCHECK --interval=30s --timeout=10s --retries=5 CMD curl -f http://localhost:8088/health || exit 1

# Initialize & start Superset
CMD /app/.venv/bin/superset db upgrade && \
    /app/.venv/bin/superset init && \
    /app/.venv/bin/gunicorn --bind 0.0.0.0:8088 "superset.app:create_app()"
