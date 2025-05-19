import logging
import requests
import json
from typing import Tuple, List, Dict
from time import time
from pandas import DataFrame, json_normalize



logger = logging.getLogger("CryptoAPI")



class CryptoAPI:



    def __init__(self,
                 crypto_currency: str,
                 local_currency: str,
                 batch_size: int,
                 api_endpoint: str,
                 api_key: str) -> None:
        
        self.crypto_currency = crypto_currency
        self.local_currency = local_currency
        self.batch_size = batch_size
        self.api_endpoint = api_endpoint
        self.api_key = api_key
        logger.info(f"CryptoAPI initialized for {self.crypto_currency}/{self.local_currency}.")

    

    def get_historical_earliest_date(self) -> int:
    
        try:
        
            request = requests.get(f"https://min-api.cryptocompare.com/data/v2/histoday?fsym={self.crypto_currency}&tsym={self.local_currency}&allData=true&{self.api_key}")
            rep = json.loads(request.content)

            return rep["Data"]["TimeFrom"]
        
        except Exception as e:

            logger.error("Failed to fetch historical earliest date", exc_info=True)
            raise


    def get_hourly_batch_data(self, toTs: int) -> Tuple[List[Dict], int]:

        try:
        
            request = requests.get(f"https://min-api.cryptocompare.com/data/v2/{self.api_endpoint}?fsym={self.crypto_currency}&tsym={self.local_currency}&limit={str(self.batch_size)}&toTs={toTs}&{self.api_key}")
            
            if request.status_code != 200:
                raise Exception(request.content)

            rep = json.loads(request.content)
            data = list(rep["Data"]["Data"])
            batch_earliest_date = rep["Data"]["TimeFrom"]

            return data, batch_earliest_date
        
        except Exception as e:

            logger.error("Failed to fetch hourly batch data", exc_info=True)
            raise



    def get_data(self, stop_ts: int, time_column: str):

        logger.info("Fetching data from API...")

        try:

            now = time()
            hourly_data, batch_earliest_date = self.get_hourly_batch_data(now)

            while batch_earliest_date > stop_ts:

                prev_hourly_data, batch_earliest_date = self.get_hourly_batch_data(batch_earliest_date)
                
                df = json_normalize(prev_hourly_data)

                if any(ts <= stop_ts for ts in df[time_column]):
                    hourly_data += prev_hourly_data[:-1]  
                    break

                hourly_data += prev_hourly_data[:-1]

            logger.info(f"Fetched {len(hourly_data)} from API.")

            return hourly_data
        
        except Exception as e:

            logger.error("Failed during full data retrieval", exc_info=True)
            raise
    


    def _has_missing_hours(self, df: DataFrame, time_column: str) -> bool:

        try:

            df = df.sort_values(by=[time_column], ascending=True)
            df["time_diff"] = df[time_column] - df[time_column].shift(1)
            return not df.query('time_diff.notnull() & time_diff != 3600').empty
        
        except Exception as e:

            logger.error("Time gasps detected in the dataset.", exc_info=True)
            raise