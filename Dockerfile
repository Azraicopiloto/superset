# Use Apache Superset official image
FROM apache/superset:latest

# Set working directory
WORKDIR /app

# Install PostgreSQL dependencies
USER root
RUN apt-get update && apt-get install -y libpq-dev gcc && \
    pip install --no-cache-dir psycopg2-binary && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Copy your Superset config file
COPY superset_config.py /app/superset_home/superset_config.py

# Set environment variables
ENV SUPERSET_HOME=/app/superset_home
ENV FLASK_ENV=production
ENV SUPERSET_PORT=8088
ENV SUPERSET_LOAD_EXAMPLES=no
ENV SUPERSET_CONFIG_PATH=/app/superset_home/superset_config.py

# Expose the Superset port
EXPOSE 8088

# Initialize and start Superset
CMD superset db upgrade && \
    superset init && \
    gunicorn --bind 0.0.0.0:8088 "superset.app:create_app()"
