## Minimal Docker image for citygml-tools CLI.
## Usage:
##   docker build -t citygml-tools .
##   docker run --rm citygml-tools --help
##   docker run --rm -v ${PWD}:/data citygml-tools validate -i /data/input.gml

ARG CITYGML_TOOLS_VERSION=2.4.0

FROM alpine:3.21 AS fetcher
ARG CITYGML_TOOLS_VERSION
RUN apk add --no-cache ca-certificates curl unzip
RUN curl -fsSL \
    "https://github.com/citygml4j/citygml-tools/releases/download/v${CITYGML_TOOLS_VERSION}/citygml-tools-${CITYGML_TOOLS_VERSION}.zip" \
    -o /tmp/citygml-tools.zip \
    && unzip -q /tmp/citygml-tools.zip -d /opt \
    && mv "/opt/citygml-tools-${CITYGML_TOOLS_VERSION}" /opt/citygml-tools \
    && rm -f /tmp/citygml-tools.zip \
    && rm -rf /opt/citygml-tools/samples /opt/citygml-tools/license

FROM eclipse-temurin:21-jre-alpine
ARG CITYGML_TOOLS_VERSION
LABEL org.opencontainers.image.title="citygml-tools" \
      org.opencontainers.image.description="Minimal citygml-tools CLI image" \
      org.opencontainers.image.version="${CITYGML_TOOLS_VERSION}"

WORKDIR /data
COPY --from=fetcher /opt/citygml-tools /opt/citygml-tools

ENTRYPOINT ["/opt/citygml-tools/citygml-tools"]
CMD ["--help"]
