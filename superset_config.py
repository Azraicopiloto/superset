import os

# Basic connection & security
SQLALCHEMY_DATABASE_URI = os.getenv("POSTGRES_URL")
SECRET_KEY = os.getenv("SUPERSET_SECRET_KEY", "supersetSEOku2025")

# Lightweight mode for Render free tier
ROW_LIMIT = 5000
ENABLE_PROXY_FIX = True

# Disable Celery and Redis to save memory
class CeleryConfig:
    broker_url = None
    result_backend = None
CELERY_CONFIG = CeleryConfig

# Optional UX & performance tweaks
FEATURE_FLAGS = {
    "EMBEDDED_SUPERSET": True,
    "DASHBOARD_NATIVE_FILTERS": True,
}

CACHE_CONFIG = {"CACHE_TYPE": "SimpleCache", "CACHE_DEFAULT_TIMEOUT": 300}
