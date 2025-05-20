# Using SQLAlchemy 2.0.41, which is not compatible with airflow 3.0.1



import logging
from os.path import exists
from sqlalchemy import Engine, MetaData, Table, Column, select, func, INTEGER, NUMERIC, TEXT 
from sqlalchemy.schema import CreateTable, CreateSchema
from sqlalchemy_utils import database_exists, create_database
from pandas import DataFrame, read_csv



logger = logging.getLogger('Database')



def ensure_database_exists(db_uri: str) -> None:
        if not database_exists(db_uri):
            create_database(db_uri)
            logger.info(f"Created database '{db_uri}'")



def set_table(table_name: str, schema_name: str, metadata: MetaData) -> Table:
    
    return Table(
        table_name,
        metadata,
        Column("time", INTEGER, unique=True, nullable=False),
        Column("high", NUMERIC, nullable=False),
        Column("low", NUMERIC, nullable=False),
        Column("open", NUMERIC, nullable=False),
        Column("volumefrom", NUMERIC, nullable=False),
        Column("volumeto", NUMERIC, nullable=False),
        Column("close", NUMERIC, nullable=False),
        Column("conversionType", TEXT, nullable=True),
        Column("conversionSymbol", TEXT, nullable=True),
        schema=schema_name
    )



class Database:



    def __init__(self, engine: Engine, metadata: MetaData):
        
        self.engine = engine
        self.metadata = metadata
        logger.info("Database initilized.")



    def ensure_schema_exists(self, schema_name: str) -> None:
        
        try:
        
            with self.engine.connect() as conn:
                conn.execute(CreateSchema(name=schema_name, if_not_exists=True))
                conn.commit()
            
            logger.info(f"Schema '{schema_name}' ensured.")
        
        except Exception as e:
        
            logger.error(f"Failed to ensure schema '{schema_name}'", exc_info=True)
            raise



    def ensure_table_exists(self, table_name: str, schema_name: str) -> None:

        self.table_name = table_name
        table = set_table(self.table_name, schema_name, self.metadata)

        try:
        
            with self.engine.connect() as conn:
                conn.execute(CreateTable(element=table, if_not_exists=True))
                conn.commit()
        
            logger.info(f"Table '{table_name}' ensured in schema '{schema_name}'.")
        
        except Exception as e:
        
            logger.error(f"Failed to ensure table '{table_name}' in schema '{schema_name}", exc_info=True)
            raise



    def _is_table_empty(self, schema_name: str) -> bool:

        self.table = Table(self.table_name, self.metadata, autoload_with=self.engine, schema=schema_name)

        try:
        
            with self.engine.connect() as conn:
                result = conn.execute(
                    select(func.count()).select_from(self.table)
                )
        
            count = result.scalar()
        
            logger.info(f"Table '{self.table}' contains {count} rows.")
        
            return count == 0
        
        except Exception as e:
        
            logger.error("Failed to check if table is empty", exc_info=True)
            raise


    def has_archive(self, archive_path: str) -> bool:
        
        try:

            return exists(archive_path)
        
        except Exception as e:
            
            logger.error(f"Failed to check archive '{archive_path}'", exc_info=True)
            raise



    def _get_archive(self, archive_path: str) -> DataFrame:
        
        try:

            df = read_csv(archive_path)
            logger.info(f"Got archive '{archive_path}.'")
            return df

        except Exception as e:

            logger.error(f"Failed to get archive '{archive_path}'", exc_info=True)
            raise 



    def load_data(self, df: DataFrame, schema_name: str, mode: str) -> None:
        
        try:            
            
            df.to_sql(self.table_name, self.engine, schema=schema_name, if_exists=mode, index=False)
            logger.info(f"{len(df)} rows loaded into '{schema_name}.{self.table_name}' (mode={mode}).")
        
        except Exception as e:
        
            logger.error(f"Failed to load data into '{schema_name}.{self.table_name}'", exc_info=True)
            raise



    def _get_latest_table_record(self, time_column: str) -> int:

        with self.engine.connect() as conn:
            result = conn.execute(
                select(func.max(self.table.c[time_column]))
            )
            
        return result.scalar()