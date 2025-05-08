import os

API_KEY = os.environ.get("CRYPTO_API_KEY")
CRYPTO_CURRENCY = "BTC"
LOCAL_CURRENCY = "EUR"
BATCH_SIZE = 2000
API_ENDPOINT = "histohour"

PG_USERNAME = "postgres"
PG_PASSWORD = os.environ.get("PG_PASSWORD")
DB_NAME = "dev"