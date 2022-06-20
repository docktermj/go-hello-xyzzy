# go-hello-xyzzy

## Demonstration

### Create stack for testing

1. Build Senzing installer.

    ```console
    curl -X GET \
        --output /tmp/senzing-versions-latest.sh \
        https://raw.githubusercontent.com/Senzing/knowledge-base/main/lists/senzing-versions-latest.sh
    source /tmp/senzing-versions-latest.sh

    sudo docker build \
        --build-arg SENZING_ACCEPT_EULA=I_ACCEPT_THE_SENZING_EULA \
        --build-arg SENZING_APT_INSTALL_PACKAGE=senzingapi=${SENZING_VERSION_SENZINGAPI_BUILD} \
        --build-arg SENZING_DATA_VERSION=${SENZING_VERSION_SENZINGDATA} \
        --no-cache \
        --tag senzing/installer:${SENZING_VERSION_SENZINGAPI} \
        https://github.com/senzing/docker-installer.git#main
    ```

1. Install Senzing.

    ```console
    curl -X GET \
        --output /tmp/senzing-versions-latest.sh \
        https://raw.githubusercontent.com/Senzing/knowledge-base/main/lists/senzing-versions-latest.sh
    source /tmp/senzing-versions-latest.sh

    sudo rm -rf /opt/senzing
    sudo mkdir -p /opt/senzing

    sudo docker run \
        --rm \
        --user 0 \
        --volume /opt/senzing:/opt/senzing \
        senzing/installer:${SENZING_VERSION_SENZINGAPI}
    ```

1. Bring up Senzing stack:

    ```console
    export DOCKER_COMPOSE_VAR=~/docker-compose-var
    export SENZING_DOCKER_COMPOSE_YAML=postgresql/docker-compose-rabbitmq-postgresql.yaml

    rm -rf ${DOCKER_COMPOSE_VAR:-/tmp/nowhere/for/safety}
    mkdir -p ${DOCKER_COMPOSE_VAR}

    curl -X GET \
        --output ${DOCKER_COMPOSE_VAR}/docker-compose.yaml \
        "https://raw.githubusercontent.com/Senzing/docker-compose-demo/main/resources/${SENZING_DOCKER_COMPOSE_YAML}"

    curl -X GET \
        --output /tmp/docker-versions-latest.sh \
        https://raw.githubusercontent.com/Senzing/knowledge-base/main/lists/docker-versions-latest.sh
    source /tmp/docker-versions-latest.sh

    export SENZING_DATA_VERSION_DIR=/opt/senzing/data
    export SENZING_ETC_DIR=/etc/opt/senzing
    export SENZING_G2_DIR=/opt/senzing/g2
    export SENZING_VAR_DIR=/var/opt/senzing

    export PGADMIN_DIR=${DOCKER_COMPOSE_VAR}/pgadmin
    export POSTGRES_DIR=${DOCKER_COMPOSE_VAR}/postgres
    export RABBITMQ_DIR=${DOCKER_COMPOSE_VAR}/rabbitmq

    sudo mkdir -p ${PGADMIN_DIR}
    sudo mkdir -p ${POSTGRES_DIR}
    sudo mkdir -p ${RABBITMQ_DIR}
    sudo chown $(id -u):$(id -g) -R ${DOCKER_COMPOSE_VAR}
    sudo chmod -R 770 ${DOCKER_COMPOSE_VAR}
    sudo chmod -R 777 ${PGADMIN_DIR}

    cd ${DOCKER_COMPOSE_VAR}
    sudo --preserve-env docker-compose up
    ```

### Demonstrate on local workstation

1. Identify git repository.

    ```console
    export GIT_ACCOUNT=docktermj
    export GIT_REPOSITORY=go-hello-xyzzy
    export GIT_ACCOUNT_DIR=~/${GIT_ACCOUNT}.git
    export GIT_REPOSITORY_DIR="${GIT_ACCOUNT_DIR}/${GIT_REPOSITORY}"
    ```

1. Using the environment variables values just set, follow steps in
   [clone-repository](https://github.com/Senzing/knowledge-base/blob/main/HOWTO/clone-repository.md) to install the Git repository.

1. Run tests.

    ```console
    cd ${GIT_REPOSITORY_DIR}
    make -e test
    ```

1. Create binary.

    ```console
    cd ${GIT_REPOSITORY_DIR}
    make clean build
    ```

1. Run binary.

    ```console
    cd ${GIT_REPOSITORY_DIR}
    make run
    ```

1. :pencil2: Set environment variables.
   Identify location of Senzing library.
   Example:

    ```console
    export LD_LIBRARY_PATH=/opt/senzing/g2/lib
    ```

   Identify Database URL of database in docker-compose stack.
   Example:

    ```console
    export XYZZY_DATABASE_URL=postgresql://postgres:postgres@127.0.0.1:5432/G2
    ```

### Demonstrate with Docker
