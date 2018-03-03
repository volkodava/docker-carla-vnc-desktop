FROM ubuntu:16.04
MAINTAINER Anatolii Volkodav <volkodavav@gmail.com>

ENV DEBIAN_FRONTEND=noninteractive

ENV USER=root
ENV HOME=/carla
WORKDIR ${HOME}

RUN sed -i -- 's/^#deb/deb/g' /etc/apt/sources.list \
    && sed -i -- 's/^# deb/deb/g' /etc/apt/sources.list \
    && apt-get update

RUN apt-get install -y locales \
    && locale-gen en_US.UTF-8

ENV TZ=Etc/UTC \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    SHELL=/bin/bash \
    SSH_PORT=2222 \
    VNC_PORT=5900 \
    DISPLAY=:0 \
    VNC_SCREEN_WHD=1280x1024x24 \
    VNC_PASSWORD=carla

RUN echo $TZ >/etc/timezone \
    && apt-get install -y tzdata \
    && rm /etc/localtime \
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
    && dpkg-reconfigure -f noninteractive tzdata

RUN apt-get install -y \
        xfce4 \
        xfce4-terminal \
        xfce4-goodies \
        firefox

RUN apt-get install -y \
        x11vnc \
        xvfb

RUN apt-get install -y supervisor

RUN apt-get install -y \
        less \
        sed \
        vim \
        mc \
        screen \
        curl \
        wget \
        sudo \
        net-tools \
        telnet \
        bzip2 \
        unzip \
        software-properties-common \
        openssh-server

RUN mkdir /var/run/sshd
RUN echo 'root:root' | chpasswd
RUN sed -ri "s/Port 22/Port ${SSH_PORT}/g" /etc/ssh/sshd_config
RUN sed -ri 's/^PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config

# see: http://carla.readthedocs.io/en/latest/how_to_build_on_linux/
RUN apt-get install -y \
        build-essential \
        clang-3.9 \
        git \
        cmake \
        strace \
        dos2unix \
        ninja-build \
        python3-pip \
        python3-requests \
        python-dev \
        autoconf \
        libtool \
        libfreetype6-dev \
        libgtk-3-dev \
        xdg-user-dirs \
        libgtkextra-dev \
        libgconf2-dev \
        libnss3 \
        libasound2 \
        libxtst-dev

RUN pip3 install --no-cache-dir protobuf

RUN update-alternatives --install /usr/bin/clang++ clang++ /usr/lib/llvm-3.9/bin/clang++ 100 \
    && update-alternatives --install /usr/bin/clang clang /usr/lib/llvm-3.9/bin/clang 100

# see: https://wiki.unrealengine.com/Building_On_Linux
RUN apt-get -y install \
    mono-mcs \
    mono-devel \
    mono-xbuild \
    mono-dmcs \
    mono-reference-assemblies-4.0 \
    libmono-system-data-datasetextensions4.0-cil \
    libmono-system-web-extensions4.0-cil \
    libmono-system-management4.0-cil \
    libmono-system-xml-linq4.0-cil \
    libmono-microsoft-build-tasks-v4.0-4.0-cil \
    clang-3.8

ENV UE4_NAME=UnrealEngine_4.18
ENV UE4_ROOT=${HOME}/${UE4_NAME}
COPY ${UE4_NAME} ${UE4_ROOT}

RUN git clone https://github.com/carla-simulator/carla.git carla-simulator
ENV CARLA_SIMULATOR=${HOME}/carla-simulator

RUN dpkg --configure -a \
    && apt-get install -f \
    && apt-get autoclean \
    && apt-get autoremove \
    && rm -rf /var/lib/apt/lists/*

COPY startup.sh ${HOME}/
COPY supervisord.conf ${HOME}/

EXPOSE ${SSH_PORT}
EXPOSE ${VNC_PORT}

RUN useradd -d ${HOME} -G adm,sudo,users -s /bin/bash build
RUN echo 'build:build' | chpasswd
RUN chown -R build:build ${HOME}
RUN chmod -R 0777 ${HOME}

USER build
WORKDIR ${UE4_ROOT}
# see: https://wiki.unrealengine.com/Building_On_Linux
RUN ./Setup.sh
RUN ./GenerateProjectFiles.sh
RUN make
RUN chmod -R 0777 ${HOME}

WORKDIR ${CARLA_SIMULATOR}
# see: http://carla.readthedocs.io/en/latest/how_to_build_on_linux/
RUN ./Setup.sh
RUN ./Rebuild.sh

USER root
WORKDIR ${HOME}
ENTRYPOINT ["./startup.sh"]
