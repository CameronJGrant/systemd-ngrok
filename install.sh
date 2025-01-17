#!/usr/bin/env bash

# determine system arch
ARCH=
if [ "$(uname -m)" == 'x86_64' ]
then
    ARCH=amd64
elif [ "$(uname -m)" == 'aarch64' ]
then
    ARCH=arm64
elif [ "$(uname -m)" == 'i386' ] || [ "$(uname -m)" == 'i686' ]
then
    ARCH=386
else
    ARCH=arm
fi

ARCHIVE=ngrok-v3-stable-linux-$ARCH.tgz
DOWNLOAD_URL=https://bin.equinox.io/c/bNyj1mQVY4c/$ARCHIVE

if [ ! $(which wget) ]; then
    echo 'Please install wget package'
    exit 1
fi

if [ ! $(which git) ]; then
    echo 'Please install git package'
    exit 1
fi

if (( $EUID != 0 )); then
    echo "Please run as root"
    exit 1
fi

if [ -z "$1" ]; then
    echo "./install.sh <your_authtoken>"
    exit 1
fi

if [ ! -e ngrok.service ]; then
    git clone --depth=1 https://github.com/vincenthsu/systemd-ngrok.git
    cd systemd-ngrok
fi

cp ngrok.service /lib/systemd/system/
cp ngrok.yml /usr/local/etc/ngrok.yml
sed -i "s/<add_your_token_here>/$1/g" /usr/local/etc/ngrok.yml

echo "Downloading ngrok for $ARCH . . ."
wget $DOWNLOAD_URL
tar xvzf $ARCHIVE -C /usr/local/bin
rm $ARCHIVE
chmod +x /usr/local/bin/ngrok

systemctl enable ngrok.service
systemctl start ngrok.service

echo "Done installing ngrok"
exit 0
