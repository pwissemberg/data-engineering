import pandas as pd
import sqlite3


hourly_df = pd.read_csv("../data/btc_hourly_data.csv")

# I should have discarded the index before exporting BTC hourly data to csv
hourly_df.drop(columns=["Unnamed: 0"], inplace=True)

hourly_df = hourly_df[["time", "high", "low", "open", "close", "volumefrom", "volumeto"]]

# Establish a connection with our database and
# Create a "Cursor" which is an object to be able to interact with the database 
# N.B: Note that the database has already been created
connection = sqlite3.connect("../database/crypto_etl.db")
cursor = connection.cursor()

for _, row in hourly_df.iterrows():
    
    time = row["time"]
    high = row["high"]
    low = row["low"]
    open = row["open"]
    close = row["close"]
    volume_from = row["volumefrom"]
    volumeto = row["volumeto"]

    cursor.execute("""
                   INSERT INTO crypto_hourly_etl (time, high, low, open, close, volume_from, volume_to) VALUES(?, ?, ?, ?, ?, ?, ?)
                   """,
                   (time, high, low, open, close, volume_from, volumeto)
                )

connection.commit()
connection.close()