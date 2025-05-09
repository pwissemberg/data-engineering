CREATE TABLE crypto_hourly_etl(

    time TIMESTAMP NOT NULL,
    high FLOAT NOT NULL,
    low FLOAT NOT NULL,
    open FLOAT NOT NULL,
    close FLOAT NOT NULL,
    volume_from FLOAT NOT NULL,
    volume_to FLOAT NOT NULL

);



CREATE TABLE crypto_hourly_elt(

    time INTEGER NOT NULL,
    high FLOAT NOT NULL,
    low FLOAT NOT NULL,
    open FLOAT NOT NULL,
    volumefrom FLOAT NOT NULL,
    volumeto FLOAT NOT NULL,
    close FLOAT NOT NULL,
    -- Strings are usually VARCHAR(n) limiting the inputs (ex: if VARCHAR(1) and username is "pwissemberg", then only "p" will be stored in db)
    -- Postgre recommends using TEXT not to limit
    -- If column names are not quoted, Postgre lowercases them, potentially leading to mismatch with sqlalchemy and dataframe
    "conversionType" TEXT,
    "conversionSymbol" TEXT

);