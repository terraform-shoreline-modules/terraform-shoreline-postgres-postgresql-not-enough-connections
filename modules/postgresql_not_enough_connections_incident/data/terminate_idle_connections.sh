bash

#!/bin/bash


# Query the pg_stat_activity view to identify idle connections

IDLE_CONNECTIONS=$(psql -h $DATABASE -p $DATABASE_PORT -U $DATABASE_USER -d $DATABASE_NAME -c "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE state = 'idle';")



# Output the number of idle connections terminated

echo "$IDLE_CONNECTIONS idle connections terminated."