#!/bin/sh -e
# A script to build the kernel .deb files, as used by Kosagi.
threads=$(($(grep '^processor' /proc/cpuinfo  | cut -d: -f2 | tail -n1)+1))
version=4.4-novena-r8

if git diff-index --name-only HEAD | grep -qv "^scripts/package"; then
	echo "Repo has local changes.  Stash or commit them."
	exit 1
fi


echo "Building v${version} with ${threads} threads"
git tag -d "v${version}" 2> /dev/null || true
git tag "v${version}"

make novena_defconfig

make -j${threads} \
	KBUILD_DEBARCH=armhf \
	KBUILD_IMAGE=zImage \
	KBUILD_DTB=imx6q-novena.dtb \
	KBUILD_DESTDIR=usr/share/linux-novena \
	KDEB_PKGVERSION=${version} \
	KDEB_PKGNAME="novena" \
	KDEB_SOURCENAME="linux-image-novena" \
	EMAIL="xobs@kosagi.com" \
	NAME="Sean Cross" \
	dtbs

# Delete the debian "files" listing, as it tends to be out of date
rm -f debian/files

make -j${threads} \
	KBUILD_DEBARCH=armhf \
	KBUILD_IMAGE=zImage \
	KBUILD_DTB=imx6q-novena.dtb \
	KBUILD_DESTDIR=usr/share/linux-novena \
	KDEB_PKGVERSION=${version} \
	KDEB_PKGNAME="novena" \
	KDEB_SOURCENAME="linux-image-novena" \
	EMAIL="xobs@kosagi.com" \
	NAME="Sean Cross" \
	deb-pkg
