
### About Shoreline
The Shoreline platform provides real-time monitoring, alerting, and incident automation for cloud operations. Use Shoreline to detect, debug, and automate repairs across your entire fleet in seconds with just a few lines of code.

Shoreline Agents are efficient and non-intrusive processes running in the background of all your monitored hosts. Agents act as the secure link between Shoreline and your environment's Resources, providing real-time monitoring and metric collection across your fleet. Agents can execute actions on your behalf -- everything from simple Linux commands to full remediation playbooks -- running simultaneously across all the targeted Resources.

Since Agents are distributed throughout your fleet and monitor your Resources in real time, when an issue occurs Shoreline automatically alerts your team before your operators notice something is wrong. Plus, when you're ready for it, Shoreline can automatically resolve these issues using Alarms, Actions, Bots, and other Shoreline tools that you configure. These objects work in tandem to monitor your fleet and dispatch the appropriate response if something goes wrong -- you can even receive notifications via the fully-customizable Slack integration.

Shoreline Notebooks let you convert your static runbooks into interactive, annotated, sharable web-based documents. Through a combination of Markdown-based notes and Shoreline's expressive Op language, you have one-click access to real-time, per-second debug data and powerful, fleetwide repair commands.

### What are Shoreline Op Packs?
Shoreline Op Packs are open-source collections of Terraform configurations and supporting scripts that use the Shoreline Terraform Provider and the Shoreline Platform to create turnkey incident automations for common operational issues. Each Op Pack comes with smart defaults and works out of the box with minimal setup, while also providing you and your team with the flexibility to customize, automate, codify, and commit your own Op Pack configurations.

# Postgresql not enough connections incident
---

The Postgresql not enough connections incident type refers to an issue where the Postgresql database instance has reached its maximum allowed connections limit, causing new connection requests to fail. This can result in application errors and downtime until the issue is resolved. The incident typically requires immediate attention from a database administrator or software engineer to increase the maximum number of allowed connections or optimize existing connections.

### Parameters
```shell
# Environment Variables

export MAX_CONNECTIONS="PLACEHOLDER"

export DATABASE_HOST="PLACEHOLDER"

export DATABASE_NAME="PLACEHOLDER"

export DATABASE_USER="PLACEHOLDER"

export DATABASE_PASSWORD="PLACEHOLDER"

export DATABASE_PORT="PLACEHOLDER"

```

## Debug

### Check the current number of connections to the Postgresql instance
```shell
sudo su - postgres -c "psql -c 'SELECT COUNT(*) FROM pg_stat_activity;'"
```

### Check the maximum allowed number of connections in the Postgresql configuration
```shell
sudo cat /etc/postgresql/main/postgresql.conf | grep max_connections
```

### Check the current memory usage of the Postgresql instance
```shell
ps aux | grep postgres
```

### Check the current disk usage of the Postgresql instance
```shell
df -h /var/lib/postgresql
```

### Check the system logs for any errors related to Postgresql
```shell
sudo tail -n 100 /var/log/syslog | grep postgres
```

### Check the Postgresql logs for any errors or connection-related messages
```shell
sudo tail -n 100 /var/log/postgresql/postgresql-main.log | grep -i error
```

### Check the network connections to the Postgresql instance
```shell
sudo netstat -nlp | grep ${DATABASE_PORT}
```

### Check the resource usage of the Postgresql process
```shell
sudo ps -eo pid,pcpu,pmem,vsz,rss,args | grep postgres | grep -v grep
```

### A long-running query or transaction has locked the database connection, preventing new connections from being established.
```shell


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


```

## Repair

### Replace <MAX_CONNECTIONS> with the desired maximum number of allowed connections
```shell
MAX_CONNECTIONS=${MAX_CONNECTIONS}
```

### Modify the postgresql.conf file to set the max_connections parameter
```shell
sudo sed -i "s/^#*max_connections *= *[0-9]\+$/max_connections = $MAX_CONNECTIONS/" /etc/postgresql/main/postgresql.conf
```

### Restart the Postgresql service to apply the configuration changes
```shell
sudo service postgresql restart
```

### Use psql to verify the new maximum number of allowed connections
```shell
psql -U $DATABASE_USER -d $DATABASE_NAME -c "SHOW max_connections;"
```

### Identify and terminate idle or inactive connections to free up resources for new connection requests. This can be done using the pg_stat_activity view or a third-party monitoring tool.
```shell
bash

#!/bin/bash


# Query the pg_stat_activity view to identify idle connections

IDLE_CONNECTIONS=$(psql -h $DATABASE -p $DATABASE_PORT -U $DATABASE_USER -d $DATABASE_NAME -c "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE state = 'idle';")



# Output the number of idle connections terminated

echo "$IDLE_CONNECTIONS idle connections terminated."


```