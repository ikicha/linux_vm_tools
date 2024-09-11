#!/bin/bash

pushd $(dirname $0) > /dev/null
tempdir=$(mktemp -d)
echo Get Debian image and dependencies...
wget -q https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-nocloud-amd64.raw -O ${tempdir}/debian.img
wget -q https://github.com/tsl0922/ttyd/releases/download/1.7.7/ttyd.x86_64 -O ${tempdir}/ttyd

echo Customize the image...
virt-customize --commands-from-file <(sed "s|/tmp|$tempdir|g" commands) -a ${tempdir}/debian.img

output_dir=out/linux
mkdir -p ${output_dir}

echo Copy files...

pushd ${tempdir} > /dev/null
virt-get-kernel -a debian.img
mv vmlinuz* vmlinuz
mv initrd.img* initrd.img
tar czvS -f images.tar.gz debian.img vmlinuz initrd.img
popd > /dev/null
mv ${tempdir}/images.tar.gz ${output_dir}/images.tar.gz
cp vm_config_x86_64.json ${output_dir}/vm_config.json

echo Calculating hash...
hash=$(cat ${output_dir}/images.tar.gz ${output_dir}/vm_config.json | sha1sum | cut -d' ' -f 1)
echo ${hash} > ${output_dir}/hash

popd > /dev/null
echo Cleaning up...
rm -rf ${tempdir}
