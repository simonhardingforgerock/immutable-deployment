ARG BUILD_TAG=latest

FROM forgerock/immutable/java:${BUILD_TAG} AS extract-container
ADD _binaries/amster.zip /

RUN mkdir -p /var/tmp/amster && \
    unzip -q /amster.zip -d /var/tmp/amster

FROM forgerock/immutable/java:${BUILD_TAG}

COPY --from=extract-container /var/tmp/amster /opt/amster
COPY amster/*.sh /opt/amster/
COPY amster/config /opt/amster/config
COPY amster/scripts /opt/amster/scripts

RUN curl https://stash.forgerock.org/projects/COM/repos/amadminpwdgen/raw/out/artifacts/amadminpwdgen_jar/amadminpwdgen.jar?at=refs%2Fheads%2Fmaster --output /opt/amster/amadminpwdgen.jar

WORKDIR /opt/amster
USER forgerock
ENTRYPOINT ["/opt/amster/docker-entrypoint.sh"]
CMD ["configure"]