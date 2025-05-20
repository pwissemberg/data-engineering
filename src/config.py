import os

# API
API_KEY = os.environ.get("CRYPTO_API_KEY")
CRYPTO_CURRENCY = "BTC"
LOCAL_CURRENCY = "EUR"
BATCH_SIZE = 2000
API_ENDPOINT = "histohour"
TIME_COLUMN = "time"

# Database
PG_USERNAME = "postgres"
PG_PASSWORD = os.environ.get("PG_PASSWORD")
#DB_NAME = "dev"
DB_NAME = "staging"
DB_URI = f"postgresql+pg8000://{PG_USERNAME}:{PG_PASSWORD}@localhost:5432/{DB_NAME}" 
#DB_SCHEMA = "public"
DB_SCHEMA = ["bronze", "silver", "gold"]
TABLE_NAME = f"{CRYPTO_CURRENCY.lower()}_{LOCAL_CURRENCY.lower()}_hourly"
ARCHIVE_FOLDER = "../data/"
ARCHIVE_FILE = f"{CRYPTO_CURRENCY.lower()}_{LOCAL_CURRENCY.lower()}_hourly.csv"
ARCHIVE_PATH = ARCHIVE_FOLDER + ARCHIVE_FILE

LOG_FOLDER = "../log/"
LOG_FILE = "elt.log"
LOG_PATH = LOG_FOLDER + LOG_FILE