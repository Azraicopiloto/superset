FROM apache/superset:latest

# Switch to root user for system installs
USER root
WORKDIR /app

# Install PostgreSQL libraries and compiler
RUN apt-get update && apt-get install -y libpq-dev gcc curl && rm -rf /var/lib/apt/lists/*

# Install psycopg2 using Superset's Python (works even if venv isn’t yet created)
RUN python3 -m pip install --no-cache-dir --upgrade pip psycopg2-binary

# Copy your Superset config
COPY superset_config.py /app/superset_config.py

# Environment variables
ENV SUPERSET_HOME=/app/superset_home
ENV FLASK_ENV=production
ENV SUPERSET_PORT=8088
ENV SUPERSET_LOAD_EXAMPLES=no
ENV SUPERSET_CONFIG_PATH=/app/superset_config.py

# Health check for Render
HEALTHCHECK --interval=30s --timeout=10s --retries=5 CMD curl -f http://localhost:8088/health || exit 1

EXPOSE 8088

# Initialize & start Superset
CMD superset db upgrade && \
    superset init && \
    gunicorn --bind 0.0.0.0:8088 "superset.app:create_app()"
