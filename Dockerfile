# syntax=docker/dockerfile:1.4
FROM openjdk:8-jdk as base

ARG TIBCO_VERSION=7.9.1
ARG INSTALLER_URL=https://sourceforge.net/projects/jasperserver/files/JasperServer/JasperReports%20Server%20Community%20$TIBCO_VERSION/TIB_js-jrs-cp_$TIBCO_VERSION_linux_x86_64.run/download

RUN apt-get update && apt-get install -y wget unzip fontconfig ttf-dejavu-core libfontconfig1 libfreetype6 libx11-6 && \
    mkdir /build && cd /build && \
    wget -O installer.run "$INSTALLER_URL" && \
    chmod +x installer.run && \
    echo -e "n\nn\nn\nn\nn\nn\nn\nn\nn\nn\n" | ./installer.run

# Create final image
FROM openjdk:8-jre-slim

COPY --from=base /build/jasperserver /opt/jasperserver
COPY drivers/*.jar /opt/jasperserver/buildomatic/conf_source/db/drivers/
COPY config/default_master.properties /opt/jasperserver/buildomatic/default_master.properties
COPY scripts/docker-entrypoint.sh /entrypoint.sh

ENV PATH="/opt/jasperserver/apache-tomcat/bin:$PATH"
WORKDIR /opt/jasperserver

RUN chmod +x /entrypoint.sh

EXPOSE 8080
ENTRYPOINT ["/entrypoint.sh"]
