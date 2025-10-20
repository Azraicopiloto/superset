FROM apache/superset:latest

WORKDIR /app

# Copy your custom config file into the container
COPY superset/superset_config.py /app/superset_config.py

ENV SUPERSET_HOME=/app/superset_home
ENV FLASK_ENV=production
ENV SUPERSET_PORT=8088
ENV SUPERSET_LOAD_EXAMPLES=no
ENV SUPERSET_CONFIG_PATH=/app/superset_config.py

EXPOSE 8088

CMD superset db upgrade && \
    superset init && \
    gunicorn --bind 0.0.0.0:8088 "superset.app:create_app()"
