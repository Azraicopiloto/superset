# -------------------------------------------------------
# Apache Superset - Final Stable Build (Render Compatible)
# -------------------------------------------------------

FROM apache/superset:3.1.2

USER root
WORKDIR /app

# Install PostgreSQL client
RUN apt-get update && \
    apt-get install -y --no-install-recommends libpq-dev gcc postgresql-client && \
    rm -rf /var/lib/apt/lists/*

# Copy your Superset config and entrypoint
COPY superset_config.py /app/superset_config.py
COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

# Environment setup
ENV SUPERSET_HOME=/app/superset_home
ENV FLASK_DEBUG=0
ENV SUPERSET_PORT=8088
ENV SUPERSET_LOAD_EXAMPLES=no
ENV SUPERSET_CONFIG_PATH=/app/superset_config.py

EXPOSE 8088

# Run Superset setup script through bash (keeps vars intact)
ENTRYPOINT ["bash", "-c", "/app/entrypoint.sh"]
