FROM google/cloud-sdk

MAINTAINER Derek Benson <d.benson@uq.edu.au>

COPY packages_dir /packages_dir

# PACKAGE lists
ENV BUILD_PACKAGES="curl git libssl-dev binutils build-essential libbz2-dev libreadline-dev libsqlite3-dev"
ENV IMAGE_PACKAGES="r-cran-rjava"

# Runtime Environment - a bit early but may as well set it up once
ENV PATH="//.pyenv/plugins/pyenv-virtualenv/shims://.pyenv/shims://.pyenv/bin:/usr/lib/jvm/java-8-openjdk-amd64/bin:/usr/local/stow/japsa/bin:${PATH}"

# Install java8
RUN echo "deb http://http.debian.net/debian jessie-backports main" >/etc/apt/sources.list.d/jessie-backports.list
RUN apt-get update && apt-get -y install $BUILD_PACKAGES $IMAGE_PACKAGES
RUN apt-get -y install -t jessie-backports openjdk-8-jdk-headless

# Install python 3.5 and albacore
RUN curl -L https://raw.githubusercontent.com/yyuu/pyenv-installer/master/bin/pyenv-installer | bash
RUN eval "$(pyenv init -)" && eval "$(pyenv virtualenv-init -)" && pyenv install 3.5.2 && pyenv global 3.5.2
RUN pip3 install packages_dir/ont_albacore-1.1.0-cp35-cp35m-manylinux1_x86_64.whl

# install japsa
RUN cd /usr/local/src && git clone https://github.com/mdcao/japsa
RUN cd /usr/local/src/japsa && make install INSTALL_DIR=/usr/local/stow/japsa MXMEM=4096M SERVER=true JLP=/usr/lib/R/site-library/rJava/jri

# Copy preinstalled version of bwa into PATH
RUN cp /packages_dir/*.pl /packages_dir/bwa /usr/local/bin

# Cleanup
RUN apt-get -y remove $BUILD_PACKAGES
