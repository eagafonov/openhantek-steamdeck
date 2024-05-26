all: image run-build

IMAGE_TAG:=localhost:5000/openhuntek-steamdec/devenv

# Command to build/test the devenv container
image:
	docker build --progress=plain \
		--build-arg DEV_UID=$(shell id -u) \
		--build-arg DEV_GID=$(shell id -g) \
		--tag ${IMAGE_TAG} \
		docker

run-shell-root:
	docker run --rm -it \
		${IMAGE_TAG} bash

#########################################
# Commnds to run stuff in the container
#########################################

RUN:=docker run --rm -it \
	--user $(shell id -u):$(shell id -g) \
	--volume $(shell pwd):/devenv \
	${IMAGE_TAG}

run-shell:
	${RUN} bash

run-build:
	${RUN} make build

#########################################
# Command to run in the devenv container
#########################################

SOURCE_DIR:=$(shell pwd)/openhantek
BUILD_DIR:=$(shell pwd)/build-steamdeck

clean:
	rm -rf ${BUILD_DIR}

.check-devenv-container:
	@test -f /STEAMDECK_DEVENV || (echo "Please run inside the devenv container" && exit 1)

configure: ${BUILD_DIR}/Makefile

${BUILD_DIR}/Makefile: .check-devenv-container ${BUILD_DIR}
	cd ${BUILD_DIR} && cmake ${SOURCE_DIR}

${BUILD_DIR}:
	mkdir -p ${BUILD_DIR}

build: .check-devenv-container ${BUILD_DIR}/Makefile
	make -C ${BUILD_DIR} -j10
