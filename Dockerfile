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
  apt --yes install psmisc
  apt --yes install libcurl4             # required by mruby-curl
  apt --yes install libcurl4-openssl-dev # required by mruby-curl
EOT

ARG MRBIMG_WORK_DIR=/mruby_build
ARG MRBIMG_BUILD_DIR="${MRBIMG_WORK_DIR}/mruby/build/host"
ARG MRBIMG_INSTALL_DIR=/opt/mruby

WORKDIR $MRBIMG_WORK_DIR

RUN <<EOT bash -xev
  git clone https://github.com/mruby/mruby.git
EOT

COPY build_config/mruby_docker.rb "${MRBIMG_WORK_DIR}/mruby/build_config/"

RUN <<EOT bash -xev
  cd mruby
  rake MRUBY_CONFIG=mruby_docker
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
  echo "export PATH=\$PATH:${MRBIMG_BUILD_DIR}/bin" >> ~/.bashrc
EOT

# Test the sh environment a Dockefile uses for heredocs
RUN <<EOT
  echo -e "\nShell process:"
  ps -p $$
  echo -e "\nShell name:"
  echo $0
  echo -e "\nSytem Info:"
  uname -a
  echo -e "\nShell option flags:"
  echo $-
  echo -e "\nLogin shell?:"
  shopt login_shell
  echo -e "\nProcess tree:"
  pstree
  echo -e "\nEnvironment variables:"
  env
EOT

# Test the environment mruby runs in as a Dockefile heredoc
RUN <<EOT /opt/mruby/bin/mruby
  puts "\nSytem Info:"
  system "uname -a"
  puts "\nShell option flags:"
  system "echo $-"
  puts "\nLogin shell?:"
  system "shopt login_shell"
  puts "Process tree\n:"
  system "pstree"
  puts "\nEnvironment variables:"
  ENV.to_hash.each { |k,v| puts "#{k} = #{v}" }
#  puts "\n:"
#  system ""
EOT

# Test if Dockerfile's heredoc sh loads from ENV
ENV ENV=.env.sh
RUN <<EOT
cat <<EOS >> /root/.env.sh
export LOADED_ENV_SH=1
echo ".env.sh loaded"
EOS
EOT

# Test if Dockerfile's heredoc sh loads from .profile
RUN <<EOT
cat <<EOS >> /root/.profile
export LOADED_PROFILE=1
echo ".profile loaded"
EOS
EOT

RUN <<EOT
  echo "Environment Variables:"
  env
EOT

WORKDIR /root

ENTRYPOINT ["/bin/bash"]
