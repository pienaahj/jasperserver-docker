#!/bin/bash
set -e

cd /opt/jasperserver/buildomatic
./js-install-ce.sh

exec catalina.sh run
