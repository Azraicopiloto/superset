FROM apache/superset:latest

# Switch to root for system installs
USER root

WORKDIR /app

# Install PostgreSQL libraries
RUN apt-get update && apt-get install -y libpq-dev gcc && rm -rf /var/lib/apt/lists/*

# Install psycopg2 globally
RUN pip install --no-cache-dir psycopg2-binary

# Copy your custom config file
COPY superset_config.py /app/superset_config.py

# Environment variables
ENV SUPERSET_HOME=/app/superset_home
ENV FLASK_ENV=production
ENV SUPERSET_PORT=8088
ENV SUPERSET_LOAD_EXAMPLES=no
ENV SUPERSET_CONFIG_PATH=/app/superset_config.py

# Expose web port for Render
EXPOSE 8088

# Initialize DB, create admin, and start Superset
CMD superset db upgrade && \
    superset fab create-admin \
        --username admin \
        --firstname Admin \
        --lastname User \
        --email admin@superset.com \
        --password admin || true && \
    superset init && \
    gunicorn --bind 0.0.0.0:$PORT "superset.app:create_app()"
