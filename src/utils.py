import requests
import json
import pandas as pd
from datetime import datetime

from variables import CRYPTO_CURRENCY, LOCAL_CURRENCY, API_KEY, API_ENDPOINT, BATCH_SIZE

def get_historical_earliest_date() -> int:
    
    request = requests.get(f"https://min-api.cryptocompare.com/data/v2/histoday?fsym={CRYPTO_CURRENCY}&tsym={LOCAL_CURRENCY}&allData=true&{API_KEY}")
    rep = json.loads(request.content)

    return rep["Data"]["TimeFrom"]



def get_hourly_batch_data(toTs: int) -> int | list:

    request = requests.get(f"https://min-api.cryptocompare.com/data/v2/{API_ENDPOINT}?fsym={CRYPTO_CURRENCY}&tsym={LOCAL_CURRENCY}&limit={str(BATCH_SIZE)}&toTs={toTs}&{API_KEY}")
    
    if request.status_code != 200:
        raise Exception(request.content)

    rep = json.loads(request.content)
    data = rep["Data"]["Data"]
    batch_earliest_date = rep["Data"]["TimeFrom"]

    return (data, batch_earliest_date)



def process_df(data: list) -> pd.DataFrame:

    # Convert list of json into a single DataFrame
    df = pd.json_normalize(data)

    # Convert date format: from integers (i.e timestamps) to dates
    df["time"] = df["time"].apply(lambda time: datetime.fromtimestamp(time))
    
    df.drop(columns=["conversionType", "conversionSymbol"], inplace=True)

    # Sort DataFrame from earliest to latest date and reset index
    df.sort_values(by=["time"], ascending=True, inplace=True)
    df.reset_index(drop=True, inplace=True)

    return df