# -------------------------------------------
# Superset Custom Config for Render (Lightweight)
# -------------------------------------------

import os

# 🗂️ Basic setup
ROW_LIMIT = 5000
SUPERSET_WEBSERVER_PORT = int(os.getenv("PORT", 8088))
ENABLE_PROXY_FIX = True

# 🔒 Security
SECRET_KEY = os.getenv("SUPERSET_SECRET_KEY", "render-light-demo-key")

# 🧠 Feature flags (only lightweight ones enabled)
FEATURE_FLAGS = {
    "EMBEDDED_SUPERSET": True,
    "DASHBOARD_NATIVE_FILTERS": True,
    "DASHBOARD_CROSS_FILTERS": False,
    "ALERT_REPORTS": False,
}

# 🚀 Performance — lightweight cache and async options off
CACHE_CONFIG = {
    "CACHE_TYPE": "SimpleCache",
    "CACHE_DEFAULT_TIMEOUT": 300,
}

# 📊 Database connection
SQLALCHEMY_DATABASE_URI = os.getenv("POSTGRES_URL", "sqlite:////tmp/superset.db")

# 🧰 Session and rate limits
SESSION_COOKIE_SAMESITE = "Lax"
SESSION_COOKIE_SECURE = True
SESSION_COOKIE_HTTPONLY = True

# 🌍 Webserver options
SUPERSET_WEBSERVER_THREADS = 2
GUNICORN_TIMEOUT = 120
ENABLE_CORS = True

# 📡 Optional: Disable some background jobs to save memory
TALISMAN_ENABLED = False
DATA_CACHE_CONFIG = None
