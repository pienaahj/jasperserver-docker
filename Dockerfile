# Base image (required by Dockerfile spec)
FROM tomcat:9-jdk17

# Accept build-time arguments with defaults to help linting tools and improve portability
ARG JRS_DB_TYPE=postgres
ARG JRS_DB_HOST=postgres
ARG JRS_DB_PORT=5432
ARG JRS_DB_NAME=jasperserver
ARG JRS_DB_USER=jasper
ARG JRS_DB_PASSWORD=jasper

# Set environment variables from build arguments
ENV JRS_DB_TYPE=${JRS_DB_TYPE} \
    JRS_DB_HOST=${JRS_DB_HOST} \
    JRS_DB_PORT=${JRS_DB_PORT} \
    JRS_DB_NAME=${JRS_DB_NAME} \
    JRS_DB_USER=${JRS_DB_USER} \
    JRS_DB_PASSWORD=${JRS_DB_PASSWORD}

# Create expected config dir
RUN mkdir -p /usr/local/share/jasperreports/buildomatic

# Copy JDBC drivers and setup scripts
COPY drivers /usr/local/tomcat/lib
COPY config/default_master.properties /usr/local/share/jasperreports/buildomatic/default_master.properties
COPY reports /usr/local/share/jasperreports/reports
COPY scripts/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh


# Install netcat and cleanup afterwards
RUN apt-get update && \
    apt-get install -y netcat-openbsd && \
    rm -rf /var/lib/apt/lists/*

# Set permissions and entrypoint
RUN chmod +x /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

# Expose web port
EXPOSE 8080