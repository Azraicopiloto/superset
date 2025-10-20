FROM apache/superset:latest

# Switch to root to install system packages
USER root

# Set working directory
WORKDIR /app

# Install PostgreSQL libraries
RUN apt-get update && apt-get install -y libpq-dev gcc && rm -rf /var/lib/apt/lists/*

# Install psycopg2-binary directly inside Superset’s virtual environment
RUN /app/.venv/bin/pip install --no-cache-dir --upgrade pip psycopg2-binary

# Copy your config file
COPY superset_config.py /app/superset_config.py

# Environment variables
ENV SUPERSET_HOME=/app/superset_home
ENV FLASK_ENV=production
ENV SUPERSET_PORT=8088
ENV SUPERSET_LOAD_EXAMPLES=no
ENV SUPERSET_CONFIG_PATH=/app/superset_config.py

EXPOSE 8088

# Run Superset initialization and start Gunicorn
CMD /app/.venv/bin/superset db upgrade && \
    /app/.venv/bin/superset init && \
    /app/.venv/bin/gunicorn --bind 0.0.0.0:8088 "superset.app:create_app()"
