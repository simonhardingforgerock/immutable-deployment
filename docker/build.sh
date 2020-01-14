#!/bin/bash

set -euo pipefail

docker build -t forgerock/immutable/java   -f java/Dockerfile .
docker build -t forgerock/immutable/tomcat -f tomcat/Dockerfile .
docker build -t forgerock/immutable/am     -f am/Dockerfile .
docker build -t forgerock/immutable/amster -f amster/Dockerfile .