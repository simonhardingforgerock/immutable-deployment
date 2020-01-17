ARG BUILD_TAG=latest

FROM forgerock/immutable/java:${BUILD_TAG} AS extractor
ADD _binaries/opendj.zip /opendj.zip

RUN mkdir -p /var/tmp/opendj && \
    unzip -q /opendj.zip -d /var/tmp/opendj

FROM forgerock/immutable/amster:${BUILD_TAG} AS amster-container
FROM forgerock/immutable/am:${BUILD_TAG} AS am-container

USER root

ENV FR_DOMAIN=example.com
ENV CTS_STORES="ctsstore-0.ctsstore"
ENV CFGDIR_USER="CN=Directory Manager"
ENV CFGDIR_PASS="password"
ENV AMADMIN_PASS="password"
ENV USRDIR_USER="CN=Directory Manager"
ENV USRDIR_PASS="password"
ENV CTSUSR_PASS="password"
ENV AM_POLICY_AGENT_PASS="password1"
ENV AM_ENC_KEY="QImJXOjsszcSffmRoGK68S0PEqtkFlFJtyoGMrT93I"


COPY --from=extractor /var/tmp/opendj /opt
COPY --from=amster-container /opt/amster /opt/amster

RUN apt-get -y install openssh-client procps && \
    export CATALINA_OPTS="-Xmx1024m -Xms1024m" && \
    echo "127.0.0.1  localds" >> /etc/hosts && \
    cat /etc/hosts && \
    cp -r /opt/opendj /opt/opendj-mock-external && \
    pushd /opt/opendj-mock-external && \
    ./setup directory-server \
    --rootUserDn "${CFGDIR_USER}" \
    --rootUserPassword "${CFGDIR_PASS}" \
    --hostname localds \
    --adminConnectorPort 1444 \
    --ldapPort 1389 \
    --profile am-cts:6.5.0 \
    --set am-cts/amCtsAdminPassword:${CFGDIR_PASS} \
    --set am-cts/tokenExpirationPolicy:ds \
    --profile am-identity-store:6.5.0 \
    --set am-identity-store/amIdentityStoreAdminPassword:${CFGDIR_PASS} \
    --profile am-config:6.5.0 \
    --set am-config/amConfigAdminPassword:${CFGDIR_PASS} \
    --acceptLicense \
    --doNotStart && \
    popd && \
    pushd /opt/opendj && \
    ./setup directory-server \
    --rootUserDn "${CFGDIR_USER}" \
    --rootUserPassword ${CFGDIR_PASS} \
    --hostname localds \
    --adminConnectorPort 2444 \
    --ldapPort 2389 \
    --profile am-config:6.5.0 \
    --set am-config/amConfigAdminPassword:${CFGDIR_PASS} \
    --acceptLicense \
    --doNotStart && \
    popd

# make temporary secrets
RUN mkdir -p /var/run/secrets/amster && \
    ssh-keygen -t rsa -b 4096 -C "amster@${FR_DOMAIN}" \
    -f /var/run/secrets/amster/id_rsa -q -N "" && \
    if ! [ -f /etc/ssl/certs/java/cacerts ]; then \
        mkdir -p /etc/ssl/certs/java && \
        ln -s $(find / -name cacerts | head -n1) /etc/ssl/certs/java/cacerts; \
    fi && \
    keytool -importkeystore \
    -srcalias tomcat \
    -trustcacerts -noprompt \
    -srckeystore /etc/ssl/certs/java/keystore.jks \
    -srcstorepass changeit \
    -destkeystore /etc/ssl/certs/java/cacerts \
    -deststorepass changeit


RUN /opt/opendj/bin/start-ds && \ 
    /opt/opendj-mock-external/bin/start-ds && \
    /usr/local/tomcat/bin/catalina.sh start && \
    tail -f /usr/local/tomcat/logs/catalina.out | while read LOGLINE; do \
        echo "${LOGLINE}"; \
        [[ "${LOGLINE}" == *"Server startup in"* ]] && pkill -P $$ tail; \
    done && \
    cd /opt/amster && \
    set -euo pipefail && \
    env && \
    echo "127.0.0.1  dynamicstore-0.dynamicstore" >> /etc/hosts && \
    echo "127.0.0.1  dynamicstore-1.dynamicstore" >> /etc/hosts && \
    echo "127.0.0.1  ctsstore-0.ctsstore" >> /etc/hosts && \
    echo "127.0.0.1  ctsstore-1.ctsstore" >> /etc/hosts && \
    echo "127.0.0.1  userstore-0.userstore">> /etc/hosts && \
    echo "127.0.0.1  userstore-1.userstore" >> /etc/hosts && \
    echo "127.0.0.1  openam" >> /etc/hosts && \
    echo "127.0.0.1  localds" >> /etc/hosts && \
    cat /etc/hosts && \
    AMSTER_SCRIPTS=/opt/amster/scripts/buildtime /opt/amster/amster-install.sh |& tee /amster.log && \
    if grep -q "IMPORT ERRORS\|SCRIPT ERROR\|Exception\|\(F\|f\)ailed\|\(U\|u\)nexpected" /amster.log; then echo "ABORTING BUILD DUE TO AMSTER ERRORS." && exit 10; fi && \
    if ! grep -q "Import completed successfully" /amster.log; then echo "ABORTING BECAUSE AMSTER IMPORT DID NOT COMPLETE." && exit 10; fi && \
    echo "Shutting down tomcat" && \
    /usr/local/tomcat/bin/catalina.sh stop && \
    sleep 10

    