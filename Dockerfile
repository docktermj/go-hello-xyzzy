# -----------------------------------------------------------------------------
# Stages
# -----------------------------------------------------------------------------

ARG IMAGE_GO_BUILDER=golang:1.18.3
ARG IMAGE_FINAL=gcr.io/distroless/base

# -----------------------------------------------------------------------------
# Stage: go_builder
# -----------------------------------------------------------------------------

FROM ${IMAGE_GO_BUILDER} as go_builder
ENV REFRESHED_AT 2022-06-11
LABEL Name="dockter/hello-xyzzy" \
      Maintainer="nemo@dockter.com" \
      Version="0.0.1"

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
RUN make target/scratch/xyzzy

# --- Test go program ---------------------------------------------------------

# Run unit tests.

# RUN go get github.com/jstemmer/go-junit-report \
#  && mkdir -p /output/go-junit-report \
#  && go test -v ${GO_PACKAGE_NAME}/... | go-junit-report > /output/go-junit-report/test-report.xml

# Set path to libraries.

ENV LD_LIBRARY_PATH=/opt/senzing/g2/lib

# Copy binaries to /output.

RUN mkdir -p /output \
 && cp -R ${GOPATH}/src/${GO_PACKAGE_NAME}/target/*  /output/

# -----------------------------------------------------------------------------
# Stage: final
# -----------------------------------------------------------------------------

FROM ${IMAGE_FINAL} as final
ENV REFRESHED_AT 2022-06-11a
LABEL Name="dockter/hello-xyzzy" \
      Maintainer="nemo@dockter.com" \
      Version="0.0.1"

# Set path to libraries.

ENV LD_LIBRARY_PATH=/opt/senzing/g2/lib

# Copy files from prior step.

COPY --from=go_builder /output/scratch/xyzzy /xyzzy

ENTRYPOINT ["/xyzzy"]
