FROM apache/superset:3.1.2

USER root
WORKDIR /app

# Lightweight install
RUN apt-get update && \
    apt-get install -y --no-install-recommends libpq-dev gcc && \
    rm -rf /var/lib/apt/lists/*

# Install inside Superset's venv
RUN /app/.venv/bin/python -m pip install --no-cache-dir --upgrade pip psycopg2-binary Pillow

COPY superset_config.py /app/superset_config.py

ENV SUPERSET_HOME=/app/superset_home
ENV FLASK_ENV=production
ENV SUPERSET_PORT=8088
ENV SUPERSET_LOAD_EXAMPLES=no
ENV SUPERSET_CONFIG_PATH=/app/superset_config.py

EXPOSE 8088

CMD /app/.venv/bin/superset db upgrade && \
    /app/.venv/bin/superset fab create-admin \
        --username admin \
        --firstname Admin \
        --lastname User \
        --email admin@superset.com \
        --password admin || true && \
    /app/.venv/bin/superset init && \
    /app/.venv/bin/gunicorn --bind 0.0.0.0:$PORT "superset.app:create_app()"
