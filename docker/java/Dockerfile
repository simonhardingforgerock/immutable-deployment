ARG OPENJDK_VER=8 
FROM openjdk:${OPENJDK_VER}-jdk
SHELL ["/bin/bash", "-c"]

ENV FORGEROCK_HOME /home/forgerock
ENV OPENAM_HOME /home/forgerock/openam
COPY java/scripts /opt/scripts

RUN apt-get update && \
    apt-get install --no-install-recommends -y curl unzip && \
    addgroup --gid 11111 forgerock && \
    adduser --shell /bin/bash --home "$FORGEROCK_HOME" --uid 11111 --disabled-password --ingroup root --gecos 'forgerock' forgerock && \
    mkdir -p "$OPENAM_HOME" && \
    chown -R forgerock:root  "$FORGEROCK_HOME"
