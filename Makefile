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

run-%:
	${RUN} make $(subst run-,,$@)

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

################
# Misc commands
################

STEAMDECK_HOST?=steamdeck

PACKAGE_DIR:=$(shell pwd)/package/openhantek
SCRIPTS_DIR:=$(shell pwd)/scripts

package: .check-devenv-container
	-rm -rf ${PACKAGE_DIR}
	mkdir -p ${PACKAGE_DIR}/{bin,lib}

	chmod +x ${SCRIPTS_DIR}/openhantek.sh

	cp ${BUILD_DIR}/openhantek/OpenHantek \
		${PACKAGE_DIR}/bin

	cp /usr/lib/libfftw3.so.* ${PACKAGE_DIR}/lib

	cp -r ${SCRIPTS_DIR}/openhantek.sh ${PACKAGE_DIR}

send-to-steamdeck:
	rsync -avz ${PACKAGE_DIR}/ deck@${STEAMDECK_HOST}:openhantek
