import time
import pandas as pd
from sqlalchemy import create_engine


from utils import get_historical_earliest_date, get_hourly_batch_data, process_df


historical_earliest_date = get_historical_earliest_date()

now = time.time()
hourly_data, batch_earliest_date = get_hourly_batch_data(now)
hourly_data, batch_earliest_date

while batch_earliest_date > historical_earliest_date:

    prev_hourly_data, batch_earliest_date = get_hourly_batch_data(batch_earliest_date)
    hourly_data += list(prev_hourly_data)

hourly_df = pd.json_normalize(hourly_data)

# Load data into database
engine = create_engine("sqlite:///../database/crypto.db")
hourly_df.to_sql("crypto_hourly_elt", engine, if_exists="append", index=False)