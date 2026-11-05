## Minimal Docker image for citygml-tools CLI.
## Usage:
##   docker build -t citygml-tools .
##   docker run --rm citygml-tools --help
##   docker run --rm -v ${PWD}:/data citygml-tools validate -i /data/input.gml

ARG CITYGML_TOOLS_VERSION=2.4.1
# SHA-256 of the release zip; must be updated together with CITYGML_TOOLS_VERSION.
ARG CITYGML_TOOLS_SHA256=89c41ecb602a3f4a628c646ac3eb5aeffdc4c62ab07f1b20f1bd2efb65561806

FROM alpine:3.24.3@sha256:be2656061b536c1883c4034790e21d0a09c5aaaf51968b89368a3c0371ea2c9a AS fetcher
ARG CITYGML_TOOLS_VERSION
ARG CITYGML_TOOLS_SHA256
RUN apk add --no-cache ca-certificates curl unzip
RUN curl -fsSL \
    "https://github.com/citygml4j/citygml-tools/releases/download/v${CITYGML_TOOLS_VERSION}/citygml-tools-${CITYGML_TOOLS_VERSION}.zip" \
    -o /tmp/citygml-tools.zip \
    && echo "${CITYGML_TOOLS_SHA256}  /tmp/citygml-tools.zip" | sha256sum -c - \
    && unzip -q /tmp/citygml-tools.zip -d /opt \
    && mv "/opt/citygml-tools-${CITYGML_TOOLS_VERSION}" /opt/citygml-tools \
    && rm -f /tmp/citygml-tools.zip \
    && rm -rf /opt/citygml-tools/samples /opt/citygml-tools/license

# Replace the bundled Jackson 2.20.1 with the 2.21.8 patch release, which fixes
# known CVEs in jackson-core/-databind (there is no fixed 2.20.x release), and
# raise jackson-annotations to the matching 2.21 line. Drop this once
# citygml-tools ships Jackson >= 2.21.8.
ARG JACKSON_BUNDLED=2.20.1
ARG JACKSON_VERSION=2.21.8
ARG JACKSON_ANNOTATIONS_BUNDLED=2.20
ARG JACKSON_ANNOTATIONS_VERSION=2.21
ARG JACKSON_ANNOTATIONS_SHA256=53ca085f4a150f703f49e1aabd935bd03b43e1ea3d55d135438292af22cef56b
ARG JACKSON_CORE_SHA256=604ef7765013daf5cde192e40bc4c8412c4ca93f4aaf7bf8e9a62fad1e1026bb
ARG JACKSON_DATABIND_SHA256=ad77f2285717e2f34c319d988b7c85783a47d0b33f33a501d1fcbf196e61bbaa
RUN set -eu; cd /opt/citygml-tools/lib; \
    for spec in \
      "jackson-annotations ${JACKSON_ANNOTATIONS_BUNDLED} ${JACKSON_ANNOTATIONS_VERSION} ${JACKSON_ANNOTATIONS_SHA256}" \
      "jackson-core ${JACKSON_BUNDLED} ${JACKSON_VERSION} ${JACKSON_CORE_SHA256}" \
      "jackson-databind ${JACKSON_BUNDLED} ${JACKSON_VERSION} ${JACKSON_DATABIND_SHA256}"; do \
      set -- $spec; \
      test -f "$1-$2.jar"; \
      curl -fsSL -o "$1-$3.jar" \
        "https://repo1.maven.org/maven2/com/fasterxml/jackson/core/$1/$3/$1-$3.jar"; \
      echo "$4  $1-$3.jar" | sha256sum -c -; \
      rm "$1-$2.jar"; \
      sed -i "s/$1-$2\.jar/$1-$3.jar/g" /opt/citygml-tools/citygml-tools; \
      if grep -q "$1-$2\.jar" /opt/citygml-tools/citygml-tools; then exit 1; fi; \
    done

FROM eclipse-temurin:21.0.13_9-jre-alpine-3.24@sha256:82cf3d9ccbe1ed46252008d51b2f2329e6b9e8a2f4394c4bebefc3ea7f4b1372
ARG CITYGML_TOOLS_VERSION
LABEL org.opencontainers.image.title="citygml-tools" \
      org.opencontainers.image.description="Minimal citygml-tools CLI image" \
      org.opencontainers.image.version="${CITYGML_TOOLS_VERSION}"

# Pick up OS security fixes that are not yet in the upstream base image.
RUN apk upgrade --no-cache

WORKDIR /data
COPY --from=fetcher /opt/citygml-tools /opt/citygml-tools

USER 1000:1000
ENTRYPOINT ["/opt/citygml-tools/citygml-tools"]
CMD ["--help"]
