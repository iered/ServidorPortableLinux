#!/bin/sh

#http://archive.canonical.com/pool/partner/a/adobe-flashplugin/adobe-flashplugin_20150623.1.orig.tar.gz
#cp i386/libflashlayer.so /usr/lib/flashplugin-installer/
mkdir /tmp/flash
tar -zxvf adobe-flashplugin.tar.gz -C /tmp/flash
install -m 644 /tmp/flash/i386/libflashplayer.so /usr/lib/flashplugin-installer/
cp -r /tmp/flash/i386/usr/* /usr
#update-alternatives --quiet --auto "mozilla-flashplugin"
update-alternatives --quiet --install "/usr/lib/mozilla/plugins/flashplugin-alternative.so" "mozilla-flashplugin" /usr/lib/flashplugin-installer/libflashplayer.so 50
rm -rf /tmp/flash
echo "Flash Plugin instalado."
