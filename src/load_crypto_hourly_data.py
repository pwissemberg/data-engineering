import pandas as pd
# import sqlite3
from sqlalchemy import create_engine


from variables import PG_USERNAME, PG_PASSWORD, DB_NAME


hourly_df = pd.read_csv("../data/btc_hourly_data.csv")

# I should have discarded the index before exporting BTC hourly data to csv
hourly_df.drop(columns=["Unnamed: 0"], inplace=True)

hourly_df = hourly_df[["time", "high", "low", "open", "close", "volumefrom", "volumeto"]]

hourly_df.rename(columns={
    "volumefrom":"volume_from",
    "volumeto": "volume_to"
}, inplace=True)

hourly_df["time"] = pd.to_datetime(hourly_df["time"])

# Establish a connection with our database and
# Create a "Cursor" which is an object to be able to interact with the database 
# N.B: Note that the database has already been created
"""
connection = sqlite3.connect("../database/crypto.db")
cursor = connection.cursor()

for _, row in hourly_df.iterrows():
    
    time = row["time"]
    high = row["high"]
    low = row["low"]
    open = row["open"]
    close = row["close"]
    volume_from = row["volumefrom"]
    volumeto = row["volumeto"]

    cursor.execute(
                   INSERT INTO crypto_hourly_etl (time, high, low, open, close, volume_from, volume_to) VALUES(?, ?, ?, ?, ?, ?, ?)
                   ,
                   (time, high, low, open, close, volume_from, volumeto)
                )

connection.commit()
connection.close()
"""

engine = create_engine(f"postgresql+pg8000://{PG_USERNAME}:{PG_PASSWORD}@localhost:5432/{DB_NAME}")

hourly_df.to_sql("crypto_hourly_etl", engine, if_exists="append", index=False)