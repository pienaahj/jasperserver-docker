#!/bin/bash
set -e

echo "🟢 Starting JasperReports Server Entrypoint"

JRS_HOME=/usr/local/share/jasperreports
DEFAULT_PROPS="$JRS_HOME/default_master.properties"
BUILDOMATIC="$JRS_HOME/jasperreports-server/buildomatic"

# Wait for database to become available
wait_for_db() {
  echo "⏳ Waiting for database at $JRS_DB_HOST:$JRS_DB_PORT..."

  for i in {1..30}; do
    if nc -z "$JRS_DB_HOST" "$JRS_DB_PORT"; then
      echo "✅ Database is reachable"
      return 0
    fi
    echo "Still waiting... ($i)"
    sleep 2
  done

  echo "❌ ERROR: Database at $JRS_DB_HOST:$JRS_DB_PORT not reachable after 60s"
  exit 1
}

initialize_jasperserver() {
  echo "Initializing JasperReports Server with DB type '$JRS_DB_TYPE'..."

  case "$JRS_DB_TYPE" in
    postgres|mysql|mariadb)
      ;;
    *)
      echo "Unsupported JRS_DB_TYPE: $JRS_DB_TYPE"
      exit 1
      ;;
  esac


#   cp /usr/local/share/jasperreports/default_master.properties /usr/local/share/jasperreports/buildomatic/default_master.properties

  cd /usr/local/share/jasperreports/buildomatic

  ./js-ant clean-config
  ./js-ant import-minimal-pro

  ./js-ant init-js-db-ce
  ./js-ant import-sample-data-ce
  ./js-ant deploy-webapp-ce

  echo "JasperReports Server initialization complete."
}

main() {
  wait_for_db

  if [ ! -f /usr/local/tomcat/webapps/jasperserver.war ]; then
    initialize_jasperserver
  else
    echo "JasperReports already initialized. Skipping setup."
  fi

  exec catalina.sh run
}

main "$@"
