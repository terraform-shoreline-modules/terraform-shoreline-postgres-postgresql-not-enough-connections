resource "shoreline_notebook" "postgresql_not_enough_connections_incident" {
  name       = "postgresql_not_enough_connections_incident"
  data       = file("${path.module}/data/postgresql_not_enough_connections_incident.json")
  depends_on = [shoreline_action.invoke_db_connection_checker,shoreline_action.invoke_terminate_idle_connections]
}

resource "shoreline_file" "db_connection_checker" {
  name             = "db_connection_checker"
  input_file       = "${path.module}/data/db_connection_checker.sh"
  md5              = filemd5("${path.module}/data/db_connection_checker.sh")
  description      = "A long-running query or transaction has locked the database connection, preventing new connections from being established."
  destination_path = "/agent/scripts/db_connection_checker.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "terminate_idle_connections" {
  name             = "terminate_idle_connections"
  input_file       = "${path.module}/data/terminate_idle_connections.sh"
  md5              = filemd5("${path.module}/data/terminate_idle_connections.sh")
  description      = "Identify and terminate idle or inactive connections to free up resources for new connection requests. This can be done using the pg_stat_activity view or a third-party monitoring tool."
  destination_path = "/agent/scripts/terminate_idle_connections.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_action" "invoke_db_connection_checker" {
  name        = "invoke_db_connection_checker"
  description = "A long-running query or transaction has locked the database connection, preventing new connections from being established."
  command     = "`chmod +x /agent/scripts/db_connection_checker.sh && /agent/scripts/db_connection_checker.sh`"
  params      = ["DATABASE_USER","DATABASE_PASSWORD","DATABASE_NAME","DATABASE_HOST","MAX_CONNECTIONS","DATABASE_PORT"]
  file_deps   = ["db_connection_checker"]
  enabled     = true
  depends_on  = [shoreline_file.db_connection_checker]
}

resource "shoreline_action" "invoke_terminate_idle_connections" {
  name        = "invoke_terminate_idle_connections"
  description = "Identify and terminate idle or inactive connections to free up resources for new connection requests. This can be done using the pg_stat_activity view or a third-party monitoring tool."
  command     = "`chmod +x /agent/scripts/terminate_idle_connections.sh && /agent/scripts/terminate_idle_connections.sh`"
  params      = ["DATABASE_USER","DATABASE_NAME","DATABASE_PORT"]
  file_deps   = ["terminate_idle_connections"]
  enabled     = true
  depends_on  = [shoreline_file.terminate_idle_connections]
}

