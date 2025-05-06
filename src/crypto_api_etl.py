import time


from utils import get_historical_earliest_date, get_hourly_batch_data, process_df


historical_earliest_date = get_historical_earliest_date()

now = time.time()
hourly_data, batch_earliest_date = get_hourly_batch_data(now)


while batch_earliest_date > historical_earliest_date:

    prev_hourly_data, batch_earliest_date = get_hourly_batch_data(batch_earliest_date)
    hourly_data += list(prev_hourly_data)


hourly_df = process_df(hourly_data)
print(hourly_df)