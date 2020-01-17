ARG OPENJDK_VER=8 
ARG TOMCAT_VER=8.5
FROM tomcat:${TOMCAT_VER}-jdk${OPENJDK_VER}-openjdk
SHELL ["/bin/bash", "-c"]

ENV FORGEROCK_HOME /home/forgerock
ENV OPENAM_HOME /home/forgerock/openam
COPY java/scripts /opt/scripts

ADD https://github.com/krallin/tini/releases/download/v0.18.0/tini /usr/bin

RUN apt-get update && \
    apt-get install --no-install-recommends -y curl && \
    rm -fr "$CATALINA_HOME"/webapps/* && \
    addgroup --gid 11111 forgerock && \
    adduser --shell /bin/bash --home "$FORGEROCK_HOME" --uid 11111 --disabled-password --ingroup root --gecos 'forgerock' forgerock && \
    mkdir -p "$OPENAM_HOME" && \
    chown -R forgerock:root "$CATALINA_HOME" && \
    chown -R forgerock:root  "$FORGEROCK_HOME" && \
    chmod -R g+rwx "$CATALINA_HOME"