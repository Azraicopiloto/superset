FROM apache/superset:latest

# Switch to root to install system dependencies
USER root
WORKDIR /app

# Install PostgreSQL development libraries
RUN apt-get update && apt-get install -y libpq-dev gcc && rm -rf /var/lib/apt/lists/*

# Install psycopg2 INSIDE Superset's virtual environment
RUN /app/.venv/bin/python -m pip install --no-cache-dir --upgrade pip psycopg2-binary

# Copy your Superset config
COPY superset_config.py /app/superset_config.py

# Set environment variables
ENV SUPERSET_HOME=/app/superset_home
ENV FLASK_ENV=production
ENV SUPERSET_PORT=8088
ENV SUPERSET_LOAD_EXAMPLES=no
ENV SUPERSET_CONFIG_PATH=/app/superset_config.py

EXPOSE 8088

# Initialize DB, create admin if not exists, and start Superset
CMD /app/.venv/bin/superset db upgrade && \
    /app/.venv/bin/superset fab create-admin \
        --username admin \
        --firstname Admin \
        --lastname User \
        --email admin@superset.com \
        --password admin || true && \
    /app/.venv/bin/superset init && \
    /app/.venv/bin/gunicorn --bind 0.0.0.0:$PORT "superset.app:create_app()"
