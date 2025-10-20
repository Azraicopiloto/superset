import os

SQLALCHEMY_DATABASE_URI = os.getenv("POSTGRES_URL")
SECRET_KEY = os.getenv("SUPERSET_SECRET_KEY", "supersetSEOku2025")

class CeleryConfig:
    broker_url = None
    result_backend = None

CELERY_CONFIG = CeleryConfig

ENABLE_PROXY_FIX = True
ROW_LIMIT = 5000
