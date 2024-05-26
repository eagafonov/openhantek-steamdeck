FROM archlinux

RUN pacman --sync --refresh --noconfirm \
    bash-completion \
    cmake \
    gcc \
    glibc \
    make \
    fftw \
    icu \
    qt5-base

ARG DEV_UID=1000
ARG DEV_GID=1000

RUN groupadd --gid ${DEV_GID} steamdev && \
    useradd --uid ${DEV_GID} --gid steamdev --shell /bin/bash --no-create-home --no-user-group steamdev

RUN mkdir -p devenv && \
    chown steamdev:steamdev /devenv

WORKDIR /devenv
VOLUME /devenv

RUN touch /STEAMDECK_DEVENV