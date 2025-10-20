# -------------------------------------------------------
# Apache Superset - Stable + Auto Admin + Migration Fix
# -------------------------------------------------------

FROM apache/superset:3.1.2

USER root
WORKDIR /app

# Install PostgreSQL client
RUN apt-get update && \
    apt-get install -y --no-install-recommends libpq-dev gcc postgresql-client && \
    rm -rf /var/lib/apt/lists/*

# Copy config & entrypoint script
COPY superset_config.py /app/superset_config.py
COPY entrypoint.sh /app/entrypoint.sh

# Ensure the script is executable
RUN chmod +x /app/entrypoint.sh

# Environment configuration
ENV SUPERSET_HOME=/app/superset_home
ENV FLASK_DEBUG=0
ENV SUPERSET_PORT=8088
ENV SUPERSET_LOAD_EXAMPLES=no
ENV SUPERSET_CONFIG_PATH=/app/superset_config.py

EXPOSE 8088

# Use entrypoint script
ENTRYPOINT ["/app/entrypoint.sh"]
