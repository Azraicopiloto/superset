FROM apache/superset:3.1.2

USER root
WORKDIR /app

# Install PostgreSQL libraries and build tools
RUN apt-get update && apt-get install -y --no-install-recommends libpq-dev gcc && rm -rf /var/lib/apt/lists/*

# Install psycopg2 and Pillow using system Python
RUN pip install --no-cache-dir --upgrade pip psycopg2-binary Pillow

# Copy Superset config
COPY superset_config.py /app/superset_config.py

# Environment
ENV SUPERSET_HOME=/app/superset_home
ENV FLASK_DEBUG=0
ENV SUPERSET_PORT=8088
ENV SUPERSET_LOAD_EXAMPLES=no
ENV SUPERSET_CONFIG_PATH=/app/superset_config.py

EXPOSE 8088

# Initialize DB and create admin user
CMD superset db upgrade && \
    superset fab create-admin \
        --username admin \
        --firstname Admin \
        --lastname User \
        --email admin@superset.com \
        --password admin --role Admin --force && \
    superset init && \
    gunicorn --bind 0.0.0.0:$PORT "superset.app:create_app()"
