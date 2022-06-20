# Makefile that builds go-hello-world, a "go" program.

# "Simple expanded" variables (':=')

# PROGRAM_NAME is the name of the GIT repository.
PROGRAM_NAME := $(shell basename `git rev-parse --show-toplevel`)
MAKEFILE_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
MAKEFILE_DIRECTORY := $(dir $(MAKEFILE_PATH))
TARGET_DIRECTORY := $(MAKEFILE_DIRECTORY)/target
DOCKER_CONTAINER_NAME := $(PROGRAM_NAME)
DOCKER_IMAGE_NAME := dockter/$(PROGRAM_NAME)
DOCKER_BUILD_IMAGE_NAME := $(DOCKER_IMAGE_NAME)-build
BUILD_VERSION := $(shell git describe --always --tags --abbrev=0 --dirty)
BUILD_TAG := $(shell git describe --always --tags --abbrev=0)
BUILD_ITERATION := $(shell git log $(BUILD_TAG)..HEAD --oneline | wc -l | sed 's/^ *//')
GIT_REMOTE_URL := $(shell git config --get remote.origin.url)
GO_PACKAGE_NAME := $(shell echo $(GIT_REMOTE_URL) | sed -e 's|^git@github.com:|github.com/|' -e 's|\.git$$||')

# Recursive assignment ('=')

CC = gcc

# Conditional assignment. ('?=')

SENZING_G2_DIR ?= /opt/senzing/g2
XYZZY_DATABASE_URL ?= postgresql://postgres:postgres@127.0.0.1:5432/G2

# The first "make" target runs as default.

.PHONY: default
default: help

# -----------------------------------------------------------------------------
# Export environment variables.
# -----------------------------------------------------------------------------

.EXPORT_ALL_VARIABLES:

# CGO_CFLAGS = -I$(MAKEFILE_DIRECTORY)lib
# CGO_LDFLAGS = -L$(MAKEFILE_DIRECTORY)lib -llibg2diagnostic

# Flags for the C compiler

CGO_CFLAGS = \
	-I${SENZING_G2_DIR}/sdk/c
	
# Flags for
	
CGO_LDFLAGS = \
	-L${SENZING_G2_DIR}/lib \
	-lanalytics \
	-lboost_atomic \
	-lboost_chrono \
	-lboost_container \
	-lboost_context \
	-lboost_contract \
	-lboost_coroutine \
	-lboost_date_time \
	-lboost_filesystem \
	-lboost_graph \
	-lboost_iostreams \
	-lboost_json \
	-lboost_locale \
	-lboost_log \
	-lboost_log_setup \
	-lboost_math_c99 \
	-lboost_math_c99f \
	-lboost_math_c99l \
	-lboost_math_tr1 \
	-lboost_math_tr1f \
	-lboost_math_tr1l \
	-lboost_nowide \
	-lboost_prg_exec_monitor \
	-lboost_program_options \
	-lboost_python39 \
	-lboost_random \
	-lboost_regex \
	-lboost_serialization \
	-lboost_system \
	-lboost_thread \
	-lboost_timer \
	-lboost_type_erasure \
	-lboost_wave \
	-lboost_wserialization \
	-ldb2plugin \
	-leaexml2 \
	-lG2 \
	-lg2AddressComp \
	-lg2AddressHasher \
	-lg2CloseNames \
	-lg2CompJavaScoreSet \
	-lg2ConfigParseAddr \
	-lg2DateComp \
	-lg2DistinctFeatJava \
	-lg2DLComp \
	-lg2EFeatJava \
	-lg2EmailComp \
	-lg2ExactDomainMatchComp \
	-lg2ExactMatchComp \
	-lg2FeatBuilder \
	-lg2FormatSSN \
	-lg2GenericHasher \
	-lg2GEOLOCComp \
	-lg2GNRNameComp \
	-lg2GroupAssociationComp \
	-lG2Hasher \
	-lg2IDHasher \
	-lg2JVMPlugin \
	-lg2NameHasher \
	-lg2ParseDOB \
	-lg2ParseEmail \
	-lg2ParseGEOLOC \
	-lg2ParseID \
	-lg2ParseName \
	-lg2ParsePhone \
	-lg2PartialAddresses \
	-lg2PartialDates \
	-lg2PartialNames \
	-lg2PhoneComp \
	-lg2PhoneHasher \
	-lG2SSAdm \
	-lg2SSNComp \
	-lg2STBHasher \
	-lg2StdCountry \
	-lg2StdJava \
	-lg2StdTokenizeName \
	-lg2StrictSubsetFelems \
	-lg2StrictSubsetNormalizedFelems \
	-lg2StrictSubsetTokens \
	-lg2StringComp \
	-licudata \
	-licui18n \
	-licuio \
	-licutest \
	-licutu \
	-licuuc \
	-lmariadbplugin \
	-lmssqlplugin \
	-lNameDataObject \
	-loracleplugin \
	-lpostal \
	-lpostgresqlplugin \
	-lscoring \
	-lSpaceTimeBoxStandardizer \
	-lsqliteplugin

LD_LIBRARY_PATH = ${SENZING_G2_DIR}/lib

# ---- Linux ------------------------------------------------------------------

target/linux:
	@mkdir -p $(TARGET_DIRECTORY)/linux || true


target/linux/$(PROGRAM_NAME): target/linux
	GOOS=linux \
	GOARCH=amd64 \
	go build \
		-a \
		-ldflags " \
			-X main.programName=${PROGRAM_NAME} \
			-X main.buildVersion=${BUILD_VERSION} \
			-X main.buildIteration=${BUILD_ITERATION} \
			" \
		-o $(TARGET_DIRECTORY)/linux/$(PROGRAM_NAME)


# -----------------------------------------------------------------------------
# Build
#   Notes:
#     "-a" needed to incorporate changes to C files.
# -----------------------------------------------------------------------------

.PHONY: dependencies
dependencies:
	@go get -u
	@go get ./...
	@go mod tidy
	@go get -u github.com/jstemmer/go-junit-report


.PHONY: build
build: dependencies \
	target/linux/$(PROGRAM_NAME)


# -----------------------------------------------------------------------------
# Test
# -----------------------------------------------------------------------------

.PHONY: test
test:
	@go test -v $(GO_PACKAGE_NAME)/...

# -----------------------------------------------------------------------------
# Run
# -----------------------------------------------------------------------------

.PHONY: run
run:
	@target/linux/$(PROGRAM_NAME)
	
# -----------------------------------------------------------------------------
# docker-build
#  - https://docs.docker.com/engine/reference/commandline/build/
# -----------------------------------------------------------------------------

.PHONY: docker-build
docker-build:
	@docker build \
		--build-arg BUILD_ITERATION=$(BUILD_ITERATION) \
		--build-arg BUILD_VERSION=$(BUILD_VERSION) \
		--build-arg GO_PACKAGE_NAME=$(GO_PACKAGE_NAME) \
		--build-arg PROGRAM_NAME=$(PROGRAM_NAME) \
		--file Dockerfile \
		--tag $(DOCKER_IMAGE_NAME) \
		--tag $(DOCKER_IMAGE_NAME):$(BUILD_VERSION) \
		.

.PHONY: docker-builder
docker-builder:
	@docker build \
		--build-arg BUILD_ITERATION=$(BUILD_ITERATION) \
		--build-arg BUILD_VERSION=$(BUILD_VERSION) \
		--build-arg GO_PACKAGE_NAME=$(GO_PACKAGE_NAME) \
		--build-arg PROGRAM_NAME=$(PROGRAM_NAME) \
		--file Dockerfile \
		--tag $(DOCKER_IMAGE_NAME) \
		--tag $(DOCKER_IMAGE_NAME):$(BUILD_VERSION) \
		--target go_builder\
		.


.PHONY: docker-build-package
docker-build-package:
	@docker build \
		--build-arg BUILD_ITERATION=$(BUILD_ITERATION) \
		--build-arg BUILD_VERSION=$(BUILD_VERSION) \
		--build-arg GO_PACKAGE_NAME=$(GO_PACKAGE_NAME) \
		--build-arg PROGRAM_NAME=$(PROGRAM_NAME) \
		--file package.Dockerfile \
		--no-cache \
		--tag $(DOCKER_BUILD_IMAGE_NAME) \
		.


.PHONY: docker-run
docker-run:
	@docker run \
	    --interactive \
	    --tty \
	    --name $(DOCKER_CONTAINER_NAME) \
	    $(DOCKER_IMAGE_NAME)

# -----------------------------------------------------------------------------
# Package
# -----------------------------------------------------------------------------

.PHONY: package
package: docker-build-package
	@mkdir -p $(TARGET_DIRECTORY) || true
	@CONTAINER_ID=$$(docker create $(DOCKER_BUILD_IMAGE_NAME)); \
	docker cp $$CONTAINER_ID:/output/. $(TARGET_DIRECTORY)/; \
	docker rm -v $$CONTAINER_ID

# -----------------------------------------------------------------------------
# Run
# -----------------------------------------------------------------------------

.PHONY: run-linux-dynamic
run-linux-dynamic:
	@target/linux/go-hello-xyzzy-dynamic

# -----------------------------------------------------------------------------
# Utility targets
# -----------------------------------------------------------------------------

.PHONY: clean
clean:
	@go clean -cache
	@docker rm --force $(DOCKER_CONTAINER_NAME) || true
	@docker rmi --force $(DOCKER_IMAGE_NAME) $(DOCKER_BUILD_IMAGE_NAME) || true
	@rm -rf $(TARGET_DIRECTORY) || true
	@rm -f $(GOPATH)/bin/$(PROGRAM_NAME) || true


.PHONY: print-make-variables
print-make-variables:
	@$(foreach V,$(sort $(.VARIABLES)), \
	   $(if $(filter-out environment% default automatic, \
	   $(origin $V)),$(warning $V=$($V) ($(value $V)))))


.PHONY: help
help:
	@echo "Build $(PROGRAM_NAME) version $(BUILD_VERSION)-$(BUILD_ITERATION)".
	@echo "All targets:"
	@$(MAKE) -pRrq -f $(lastword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$' | xargs
