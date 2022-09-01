FROM crops/yocto:ubuntu-20.04-base

USER root

# make /bin/sh symlink to bash instead of dash:
RUN echo "dash dash/sh boolean false" | debconf-set-selections
RUN DEBIAN_FRONTEND=noninteractive dpkg-reconfigure dash

COPY podman.list /etc/apt/sources.list.d/podman.list
RUN wget -L "https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/xUbuntu_20.04/Release.key" -O - | sudo apt-key add -

RUN DEBIAN_FRONTEND=noninteractive apt-get update -y
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y curl apt-utils netcat lzma-dev liblzma-dev liblzma5 xz-utils python3 python3-pip python3-distutils dos2unix
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y gawk diffstat unzip p7zip-full texinfo gcc-multilib chrpath libsdl1.2-dev xterm gperf bison g++-multilib docker.io podman
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install build-essential software-properties-common jq
RUN DEBIAN_FRONTEND=noninteractive apt-get install -f -y

RUN curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | sudo bash
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y git-core git-lfs
RUN git lfs install

RUN DEBIAN_FRONTEND=noninteractive apt-get update -y
RUN DEBIAN_FRONTEND=noninteractive apt-get dist-upgrade -y
RUN DEBIAN_FRONTEND=noninteractive apt-get autoremove -y

RUN pip3 install --upgrade pip
RUN pip3 install kas

# Install the repo command
RUN curl https://storage.googleapis.com/git-repo-downloads/repo > /usr/bin/repo
RUN chmod a+x /usr/bin/repo

RUN userdel yoctouser
# RUN groupdel yoctouser

RUN groupadd -r -g 1000 dmoseley
RUN useradd -r -u 1000 -g dmoseley -G sudo dmoseley

# RUN echo 'yoctouser:mysecretpassword' | chpasswd
RUN echo 'root:mysecretpassword' | chpasswd
RUN echo 'dmoseley:mysecretpassword' | chpasswd

RUN mkdir /home/dmoseley
RUN chown dmoseley.dmoseley /home/dmoseley

USER dmoseley
