#!/bin/bash -e

echo "edit me !!!!" ; exit 1

mybase="docker.high-con.de/debian-mini-amd64:9.8"
mycoreboot="git clone --single-branch  -b rsgw-b git@git:rsgw-coreboot coreboot"
mytag="docker.high-con.de/coreboot-sdk"

# add ssh access keys
[[ -e id_rsa ]]
[[ -e id_rsa.pub ]]

echo "FROM $mybase" > Dockerfile
echo "MAINTAINER \"Gerd Pauli <gp@high-consulting.de>\"" >> Dockerfile
echo "RUN useradd -p locked -m coreboot && apt-get update && apt-get -y install bc bison bzip2 ccache cmake curl device-tree-compiler dh-autoreconf diffutils doxygen flex g++ gawk gcc git gnat-6 graphviz libelf-dev libfreetype6-dev libftdi-dev libftdi1-dev libglib2.0-dev libgmp-dev libisl-dev liblzma-dev libncurses5-dev libpci-dev libreadline-dev libssl1.0-dev libusb-1.0-0-dev libusb-dev libxml2-dev libyaml-dev m4 make msitools nasm openssl patch pkg-config python qemu rsync shellcheck subversion unifont uuid-dev vim-common wget xz-utils zlib1g-dev gcc-multilib build-essential sudo && apt-get clean" >> Dockerfile
echo "RUN mkdir /root/.ssh && chmod 700 /root/.ssh" >> Dockerfile
echo "COPY id_rsa id_rsa.pub /root/.ssh/" >> Dockerfile
echo "COPY sudoers /etc/" >> Dockerfile
echo "RUN chown root.root /etc/sudoers && chmod 440 /etc/sudoers" >> Dockerfile
# uncomment and edit this if you need to get the actual hostkey
#echo "RUN ssh -o \"StrictHostKeyChecking=no\" git@git" >> Dockerfile
echo "RUN cd /root && ${mycoreboot} && cd coreboot/util/crossgcc && make all_without_gdb BUILD_LANGUAGES=c,ada CPUS=\$(nproc) DEST=/opt/xgcc && cd /root && rm -rf coreboot" >> Dockerfile
echo "RUN mkdir /home/coreboot/.ccache && chown coreboot:coreboot /home/coreboot/.ccache && mkdir /home/coreboot/cb_build && chown coreboot:coreboot /home/coreboot/cb_build && echo \"export PATH=$PATH:/opt/xgcc/bin\" >> /home/coreboot/.bashrc && echo \"export SDK_VERSION=hc\" >> /home/coreboot/.bashrc && echo \"export SDK_BRANCH=rsgw-b\" >> /home/coreboot/.bashrc" >> Dockerfile
echo "VOLUME [/home/coreboot/.ccache]" >> Dockerfile
echo "ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/xgcc/bin" >> Dockerfile
echo "ENV SDK_VERSION=hc" >> Dockerfile
echo "ENV SDK_BRANCH=rsgw-b" >> Dockerfile
echo "USER coreboot" >> Dockerfile

docker build -t makeit_debootstrap .
docker tag makeit_debootstrap $mytag 
docker rmi makeit_debootstrap






