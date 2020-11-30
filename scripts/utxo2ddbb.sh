#!/bin/bash

# Script to dump bitcoin utxo database to postgres database

# Install go and postgreSQL
#### apt install golang postgresql
# Stop bitcoin full node because two applications cannot access LevelDB at the same time
# Access user postgres
#### sudo su - postgres

DIR_CHAINSTATE=/mnt/hgfs/Proyect/bitcoin-utxo-dump/chainstate
DIR_DUMP=/mnt/hgfs/Proyect/bitcoin-utxo-dump/
PGPASSWORD=postgres

# Download and compile program bitcoin-utxo-dump of ins3rsha
go get github.com/in3rsha/bitcoin-utxo-dump

# Execure dump Bitcoin utxo to file
./go/bin/bitcoin-utxo-dump -db $DIR_CHAINSTATE

# Import dump in table in database
psql -d postgres -U postgres -c "DROP INDEX IF EXISTS index_address_amount;"
psql -d postgres -U postgres -c "DROP TABLE IF EXISTS utxo;"
psql -d postgres -U postgres -c "CREATE TABLE IF NOT EXISTS utxo (id INT NOT NULL, tx_id VARCHAR(100) NOT NULL, vout INT NOT NULL, amount BIGINT NOT NULL, type VARCHAR(50) NOT NULL, address VARCHAR(100));"
psql -d postgres -U postgres -c "copy utxo(id, tx_id, vout, amount, type, address) FROM '$DIR_DUMP/utxodump.csv'  DELIMITER ',' CSV HEADER;"
psql -d postgres -U postgres -c "CREATE INDEX IF NOT EXISTS index_address_amount ON utxo (address, amount);"
psql -d postgres -U postgres -c "CREATE TABLE IF NOT EXISTS address (THE_DATE DATE NOT NULL DEFAULT CURRENT_DATE, BTC000001 INT, BTC1 INT, BTC1000 INT);"

# Selects
# Address >= 0.00001 BTC
BTC000001=$(psql -d postgres -U postgres -t -c "select count(*) from (select address, sum(amount) / 100000000 as BTC from utxo group by address having sum(amount) / 100000000 >= 0.00001) B000001")
# Address >= 1 BTC
BTC1=$(psql -d postgres -U postgres -t -c "select count(*) from (select address, sum(amount) / 100000000 as BTC from utxo group by address having sum(amount) / 100000000 >= 1) B1")
# Whales Bitcoin, address >= 1000 BTC
BTC1000=$(psql -d postgres -U postgres -t -c "select count(*) from (select address, sum(amount) / 100000000 as BTC from utxo group by address having sum(amount) / 100000000 >= 1000) B1000")
psql -d postgres -U postgres -c "INSERT INTO address(BTC000001, BTC1, BTC1000) VALUES ($BTC000001, $BTC1, $BTC1000)"

psql -d postgres -U postgres -c "SELECT * FROM address"
