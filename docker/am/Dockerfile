ARG BUILD_TAG=latest

FROM forgerock/immutable/java:${BUILD_TAG} AS extractor
ADD _binaries/am.war /am.war

RUN mkdir -p /var/tmp/openam && \
    unzip -q /am.war -d /var/tmp/openam

FROM forgerock/immutable/tomcat:${BUILD_TAG}
SHELL ["/bin/bash", "-c"]

COPY am/server.xml "$CATALINA_HOME"/conf/
COPY --from=extractor /var/tmp/openam "$CATALINA_HOME"/webapps/ROOT
ENV CATALINA_OPTS "-server -Xms2048m -Xmx2048m \
  -Dcom.sun.identity.util.debug.provider=com.sun.identity.shared.debug.impl.StdOutDebugProvider \
  -Dcom.sun.identity.shared.debug.file.format=\"%PREFIX% %MSG%\\n%STACKTRACE%\""

RUN mkdir -p /etc/ssl/certs/java && \
    keytool -genkey -noprompt \
    -keyalg RSA \
    -alias tomcat \
    -dname "CN=openam, OU=ID, O=FORGEROCK, L=Boulder, S=CO, C=US" \
    -keystore /etc/ssl/certs/java/keystore.jks \
    -storepass changeit \
    -keypass changeit

ADD am/*.sh $FORGEROCK_HOME/
USER forgerock
ENTRYPOINT ["/home/forgerock/docker-entrypoint.sh"]