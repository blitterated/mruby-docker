# syntax=docker/dockerfile:1

FROM ubuntu

MAINTAINER blitterated blitterated@protonmail.com

RUN <<EOT bash -xev
  apt update && apt --yes upgrade

  apt --yes install build-essential
  apt --yes install bison
  apt --yes install gperf
  apt --yes install ruby3.0
  apt --yes install git
  apt --yes install vim
  apt --yes install file
  apt --yes install tree
EOT

ARG MRBIMG_WORK_DIR=/mruby_build
ARG MRBIMG_BUILD_DIR="${MRBIMG_WORK_DIR}/mruby/build/host"
ARG MRBIMG_INSTALL_DIR=/opt/mruby

WORKDIR $MRBIMG_WORK_DIR

RUN <<EOT bash -xev
  git clone https://github.com/mruby/mruby.git
  cd mruby
  rake
EOT


RUN <<EOT bash -xev
  shopt -s extglob
  mkdir -p "${MRBIMG_INSTALL_DIR}"/{bin,lib,mrbc/{bin,lib}}
  cp "${MRBIMG_BUILD_DIR}"/LEGAL "${MRBIMG_INSTALL_DIR}"
  cp "${MRBIMG_BUILD_DIR}"/bin/* "${MRBIMG_INSTALL_DIR}/bin"
  cp "${MRBIMG_BUILD_DIR}"/lib/*.a "${MRBIMG_INSTALL_DIR}/lib"
  cp "${MRBIMG_BUILD_DIR}"/mrbc/bin/* "${MRBIMG_INSTALL_DIR}/mrbc/bin"
  cp "${MRBIMG_BUILD_DIR}"/mrbc/lib/*.a "${MRBIMG_INSTALL_DIR}/mrbc/lib"
  cp "${MRBIMG_BUILD_DIR}"/presym "${MRBIMG_INSTALL_DIR}"
EOT

WORKDIR /root

ENTRYPOINT ["/bin/bash"]
