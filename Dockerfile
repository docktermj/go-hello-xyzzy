# -----------------------------------------------------------------------------
# Stages
# -----------------------------------------------------------------------------

ARG IMAGE_GO_BUILDER=golang:1.18.3
# ARG IMAGE_FINAL=gcr.io/distroless/base
# ARG IMAGE_FINAL=debian:11.3-slim@sha256:06a93cbdd49a265795ef7b24fe374fee670148a7973190fb798e43b3cf7c5d0f
# ARG IMAGE_FINAL=alpine:latest
ARG IMAGE_FINAL=golang:1.18.3

# -----------------------------------------------------------------------------
# Stage: go_builder
# -----------------------------------------------------------------------------

FROM ${IMAGE_GO_BUILDER} as go_builder
ENV REFRESHED_AT 2022-06-20
LABEL Name="dockter/hello-xyzzy" \
      Maintainer="nemo@dockter.com" \
      Version="0.0.2"

# Build arguments.

ARG PROGRAM_NAME="unknown"
ARG BUILD_VERSION=0.0.0
ARG BUILD_ITERATION=0
ARG GO_PACKAGE_NAME="unknown"

# Copy local files from the Git repository.

COPY . ${GOPATH}/src/${GO_PACKAGE_NAME}

# Copy remote files.

COPY --from=senzing/installer:3.1.0  "/opt/local-senzing" "/opt/senzing"

# Build go program.

WORKDIR ${GOPATH}/src/${GO_PACKAGE_NAME}
RUN make target/linux/go-hello-xyzzy

# --- Test go program ---------------------------------------------------------

# Run unit tests.

# RUN go get github.com/jstemmer/go-junit-report \
#  && mkdir -p /output/go-junit-report \
#  && go test -v ${GO_PACKAGE_NAME}/... | go-junit-report > /output/go-junit-report/test-report.xml

# Install packages via apt.

RUN apt-get update \
 && apt-get -y install \
      libaio1 \
      libodbc1 \
      librdkafka-dev \
      libssl1.1 \
      libxml2 \
      postgresql-client \
      unixodbc \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Set path to libraries.

ENV LD_LIBRARY_PATH=/opt/senzing/g2/lib

# Copy binaries to /output.

RUN mkdir -p /output \
 && cp -R ${GOPATH}/src/${GO_PACKAGE_NAME}/target/*  /output/

# -----------------------------------------------------------------------------
# Stage: final
# -----------------------------------------------------------------------------

FROM ${IMAGE_FINAL} as final
ENV REFRESHED_AT 2022-06-20
LABEL Name="dockter/hello-xyzzy" \
      Maintainer="nemo@dockter.com" \
      Version="0.0.2"

# Install packages via apt.

RUN apt-get update \
 && apt-get -y install \
      libaio1 \
      libodbc1 \
      librdkafka-dev \
      libssl1.1 \
      libxml2 \
      postgresql-client \
      unixodbc \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Set path to libraries.

ENV LD_LIBRARY_PATH=/opt/senzing/g2/lib

# Copy files from prior step.

COPY --from=go_builder /output /app

ENTRYPOINT ["/app/linux/go-hello-xyzzy"]
