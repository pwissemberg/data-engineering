import logging
from config import *
from Database import *
from CryptoAPI import *
from sqlalchemy import create_engine
from pandas import json_normalize



logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s | %(levelname)s | %(name)s | %(message)s",
    handlers=[
        logging.StreamHandler(),
        logging.FileHandler(LOG_PATH, mode="a")
    ]
)



logger = logging.getLogger("main")



if __name__ == "__main__":
     
    try:

        ensure_database_exists(DB_URI)



        engine = create_engine(DB_URI)
        metadata = MetaData()
        db = Database(engine, metadata)



        api = CryptoAPI(CRYPTO_CURRENCY, LOCAL_CURRENCY, BATCH_SIZE, API_ENDPOINT, API_KEY)



        db.ensure_schema_exists(DB_SCHEMA[0])
        db.ensure_table_exists(TABLE_NAME, DB_SCHEMA[0])



        if db._is_table_empty(DB_SCHEMA[0]):
            
            logger.info(f"Table '{DB_SCHEMA[0]}.{TABLE_NAME}' is empty.")

            if db.has_archive(ARCHIVE_PATH):
                
                logger.info("Archive found.")
                
                df = db._get_archive(ARCHIVE_PATH)
                db.load_data(df, DB_SCHEMA[0], mode="append")
                
                latest = db._get_latest_table_record(time_column=TIME_COLUMN)
                data = api.get_data(stop_ts=latest, time_column=TIME_COLUMN)
                df = json_normalize(data)
                df = df[df[TIME_COLUMN] > latest]
                
                if api._has_missing_hours(df, TIME_COLUMN):
                    logger.error("Time gasps detected in dataframe", exc_info=True)
                    raise
                else:
                    db.load_data(df, DB_SCHEMA[0], mode="append")
                    logger.info(f"{len(df)} rows loaded into '{DB_SCHEMA[0]}.{TABLE_NAME}' (mode=append).")
            
            else:
                
                logger.info(f"Archive '{ARCHIVE_PATH}' not found. Fetching full history.")

                historical_earliest_date = api.get_historical_earliest_date()
                data = api.get_data(stop_ts=historical_earliest_date, time_column=TIME_COLUMN)
                df = json_normalize(data)
                
                if api._has_missing_hours(df, TIME_COLUMN):
                    logger.error("Time gasps detected in dataframe", exc_info=True)
                    raise
                else:
                    df.to_csv(ARCHIVE_PATH, index=False)
                    db.load_data(df, DB_SCHEMA[0], mode="append")
                    logger.info(f"{len(df)} rows loaded into '{DB_SCHEMA[0]}.{TABLE_NAME}' (mode=append) and saved into {ARCHIVE_PATH}.")

        else:
            
            logger.info(f"Table '{TABLE_NAME}' has existing data.")

            latest = db._get_latest_table_record(time_column=TIME_COLUMN)
            data = api.get_data(stop_ts=latest, time_column=TIME_COLUMN)
            df = json_normalize(data)
            df = df[df[TIME_COLUMN] > latest]
            
            if api._has_missing_hours(df, TIME_COLUMN):
                logger.error("Time gasps detected in dataframe", exc_info=True)
                raise
            else:
                db.load_data(df, DB_SCHEMA[0], mode="append")
                logger.info(f"{len(df)} rows loaded into '{DB_SCHEMA[0]}.{TABLE_NAME}' (mode=append).")


        db.ensure_schema_exists(DB_SCHEMA[1])
        db.ensure_schema_exists(DB_SCHEMA[2])


    except Exception as e:

        logger.critical("Pipeline failed", exc_info=True)