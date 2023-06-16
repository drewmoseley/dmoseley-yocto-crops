FROM ubuntu:20.04

USER root
ARG TARGETPLATFORM
ARG LINUX_UID=1000
ARG LINUX_GID=1000
ARG MACOS_UID=501
ARG MACOS_GID=1000

# make /bin/sh symlink to bash instead of dash:
RUN echo "dash dash/sh boolean false" | debconf-set-selections
RUN DEBIAN_FRONTEND=noninteractive dpkg-reconfigure dash

RUN DEBIAN_FRONTEND=noninteractive apt-get update -y
# Standard Yocto requirements from https://docs.yoctoproject.org/brief-yoctoprojectqs/index.html
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y gawk wget git diffstat unzip texinfo gcc build-essential chrpath socat cpio python3 python3-pip python3-pexpect xz-utils debianutils iputils-ping python3-git python3-jinja2 libegl1-mesa libsdl1.2-dev pylint3 xterm python3-subunit mesa-common-dev zstd liblz4-tool sudo apt-utils python2.7 locales python-is-python3 libmd0 libmd-dev

# Other packages that I use
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y curl netcat lzma-dev liblzma-dev liblzma5 python3-distutils dos2unix p7zip-full docker.io jq emacs tmux keychain pass rsync bc
RUN DEBIAN_FRONTEND=noninteractive apt-get install -f -y

# Generate proper locale
RUN locale-gen en_US.UTF-8

# Install git-lfs
RUN curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | sudo bash
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y git-core git-lfs
RUN git lfs install

# Install git-delta
RUN if [ "$TARGETPLATFORM" = "linux/amd64" ]; then ARCHITECTURE=amd64; elif [ "$TARGETPLATFORM" = "linux/arm64" ]; then ARCHITECTURE=arm64; else ARCHITECTURE=amd64; fi && \
    wget https://github.com/dandavison/delta/releases/download/0.14.0/git-delta_0.14.0_${ARCHITECTURE}.deb -O /tmp/git-delta.deb
RUN DEBIAN_FRONTEND=noninteractive dpkg --install /tmp/git-delta.deb

# Install git-credential-manager
RUN if [ "$TARGETPLATFORM" = "linux/amd64" ]; then wget https://github.com/GitCredentialManager/git-credential-manager/releases/download/v2.0.877/gcm-linux_amd64.2.0.877.deb -O /tmp/gcm.deb && DEBIAN_FRONTEND=noninteractive dpkg --install /tmp/gcm.deb; fi

# Cleanup APT
RUN DEBIAN_FRONTEND=noninteractive apt-get update -y
RUN DEBIAN_FRONTEND=noninteractive apt-get dist-upgrade -y
RUN DEBIAN_FRONTEND=noninteractive apt-get autoremove -y

# Install Kas
RUN pip3 install --upgrade pip
RUN pip3 install kas

# Install repo
RUN curl https://storage.googleapis.com/git-repo-downloads/repo > /usr/bin/repo
RUN chmod a+x /usr/bin/repo

RUN groupadd -r -g 126 kvm
RUN if [ "$TARGETPLATFORM" = "linux/arm64" ]; then USER_UID=${MACOS_UID}; USER_GID=${MACOS_GID}; else USER_UID=${LINUX_UID}; USER_GID=${LINUX_GID}; fi && \
    groupadd -o -r -g ${USER_GID} dmoseley && \
    useradd -r -u ${USER_UID} -g dmoseley -G sudo,kvm dmoseley
RUN echo 'root:mysecretpassword' | chpasswd
RUN echo 'dmoseley:mysecretpassword' | chpasswd

RUN mkdir /home/dmoseley
RUN chown dmoseley.dmoseley /home/dmoseley

# Setup user dmoseley for sudo
RUN echo 'dmoseley ALL=(ALL:ALL) NOPASSWD: ALL' | sudo EDITOR='tee -a' visudo

USER dmoseley
