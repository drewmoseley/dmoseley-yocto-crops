FROM crops/yocto:ubuntu-18.04-base

USER root

# make /bin/sh symlink to bash instead of dash:
RUN echo "dash dash/sh boolean false" | debconf-set-selections
RUN DEBIAN_FRONTEND=noninteractive dpkg-reconfigure dash

RUN DEBIAN_FRONTEND=noninteractive apt-get update -y
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y curl apt-utils netcat lzma-dev liblzma-dev liblzma5 xz-utils python3 python3-distutils dos2unix
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install build-essential software-properties-common
# RUN DEBIAN_FRONTEND=noninteractive add-apt-repository ppa:ubuntu-toolchain-r/test -y
# RUN DEBIAN_FRONTEND=noninteractive apt-get install -y gcc-9 g++-9 gcc-9-multilib lib32objc-9-dev lib32stdc++-9-dev lib32gcc-9-dev libobjc-9-dev libstdc++-9-dev libgcc-9-dev
# RUN DEBIAN_FRONTEND=noninteractive update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-9 60 --slave /usr/bin/g++ g++ /usr/bin/g++-9
# RUN DEBIAN_FRONTEND=noninteractive update-alternatives --config gcc
RUN DEBIAN_FRONTEND=noninteractive apt-get install -f

RUN curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | sudo bash
RUN DEBIAN_FRONTEND=noninteractive apt-get install git-lfs
RUN git lfs install

RUN DEBIAN_FRONTEND=noninteractive apt-get update -y
RUN DEBIAN_FRONTEND=noninteractive apt-get dist-upgrade -y
RUN DEBIAN_FRONTEND=noninteractive apt-get autoremove -y

# Install the repo command
RUN curl https://storage.googleapis.com/git-repo-downloads/repo > /usr/bin/repo
RUN chmod a+x /usr/bin/repo

RUN userdel yoctouser
# RUN groupdel yoctouser

RUN groupadd -r -g 1000 dmoseley
RUN useradd -r -u 1000 -g dmoseley dmoseley

# RUN echo 'yoctouser:mysecretpassword' | chpasswd
RUN echo 'root:mysecretpassword' | chpasswd
RUN echo 'dmoseley:mysecretpassword' | chpasswd

RUN mkdir /home/dmoseley
RUN chown dmoseley.dmoseley /home/dmoseley

USER dmoseley
