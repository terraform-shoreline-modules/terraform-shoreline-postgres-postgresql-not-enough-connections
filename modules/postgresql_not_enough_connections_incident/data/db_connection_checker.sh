

#!/bin/bash



# Set database connection parameters

DB_HOST=${DATABASE_HOST}

DB_PORT=${DATABASE_PORT}

DB_NAME=${DATABASE_NAME}

DB_USER=${DATABASE_USER}

DB_PASSWORD=${DATABASE_PASSWORD}



# Check if the database is running

if ! nc -z $DB_HOST $DB_PORT; then

  echo "ERROR: Database is not running on $DB_HOST:$DB_PORT"

  exit 1

fi



# Check database connection count

CURRENT_CONNECTIONS=$(psql -h $DB_HOST -p $DB_PORT -U $DB_USER -c "SELECT count(*) FROM pg_stat_activity WHERE state = 'active';" -d $DB_NAME -t)

MAX_CONNECTIONS=$(psql -h $DB_HOST -p $DB_PORT -U $DB_USER -c "SELECT setting FROM pg_settings WHERE name = 'max_connections';" -d $DB_NAME -t)



echo "Current number of active connections: $CURRENT_CONNECTIONS"

echo "Maximum number of allowed connections: $MAX_CONNECTIONS"



# Check for long-running queries

LONG_RUNNING_QUERIES=$(psql -h $DB_HOST -p $DB_PORT -U $DB_USER -c "SELECT * FROM pg_stat_activity WHERE state = 'active' AND query_start < NOW() - INTERVAL '5 minutes';" -d $DB_NAME)



if [ -z "$LONG_RUNNING_QUERIES" ]; then

  echo "No long-running queries found."

else

  echo "The following queries are running for more than 5 minutes:"

  echo "$LONG_RUNNING_QUERIES"

fi