FROM apache/superset:latest

# Switch to root for system installs
USER root

WORKDIR /app

# Install PostgreSQL libs and build tools
RUN apt-get update && apt-get install -y libpq-dev gcc curl && rm -rf /var/lib/apt/lists/*

# Install psycopg2-binary globally so Superset can access it
RUN pip install --no-cache-dir --upgrade pip psycopg2-binary

# Copy Superset config file
COPY superset_config.py /app/superset_config.py

# Set environment variables
ENV SUPERSET_HOME=/app/superset_home
ENV FLASK_ENV=production
ENV SUPERSET_PORT=8088
ENV SUPERSET_LOAD_EXAMPLES=no
ENV SUPERSET_CONFIG_PATH=/app/superset_config.py

# Healthcheck (Render will wait until Superset is ready)
HEALTHCHECK --interval=30s --timeout=10s --retries=5 CMD curl -f http://localhost:8088/health || exit 1

EXPOSE 8088

# Initialize and run Superset
CMD superset db upgrade && \
    superset init && \
    gunicorn --bind 0.0.0.0:8088 "superset.app:create_app()"
