#!/bin/bash -ex

set -eux

if [ "$(uname -m)" = "x86_64" ]; then
    docker run --rm --privileged multiarch/qemu-user-static:register --reset
fi

rm -f qemu-*-static

# We use curl and bsdtar to obtain QEMU binaries. Install them beforehand.
sudo apt-get update -qq
DEBIAN_FRONTEND=noninteractive \
    sudo apt-get install --yes --no-install-recommends \
    ca-certificates curl libarchive-tools

# see https://gitlab.com/qemu-project/qemu/-/tags for versions;
# we use the RPMs from https://kojipkgs.fedoraproject.org/packages/qemu;
# avoid qemu builds from unreleased fedora versions, compare `build`
# vs. https://en.wikipedia.org/wiki/Fedora_Linux_release_history;
# prefer non-`.0` patch releases to try to avoid potential new regressions;
# if possible, check https://gitlab.com/qemu-project/qemu/-/issues
# for relevant issues in old vs new version;
version='8.2.8'
build='2.fc40'
for arch in aarch64 ppc64le s390x riscv64; do
    pkg_arch="${arch}"
    if [[ "${arch}" == 'ppc64le' ]]; then
        pkg_arch='ppc'
    elif [[ "${arch}" == 'riscv64' ]]; then
        pkg_arch='riscv'
    fi
    curl -sL \
        "https://kojipkgs.fedoraproject.org/packages/qemu/${version}/${build}/x86_64/qemu-user-static-${pkg_arch}-${version}-${build}.x86_64.rpm" |
        bsdtar -xf- --strip-components=3 ./usr/bin/qemu-${arch}-static
done

sha256sum --check << 'EOF'
c41cd478bdcccbc76a0e35db8ba65861038cd8f0d6339abc0cfd19eadc335fc6  qemu-aarch64-static
9b5c44f35eceaf6484ec11bc03047001293586f9ae73861dde87329243d56ae7  qemu-ppc64le-static
767a23c0ec4570b28d352ad00c55c4fc2315d5707078d022c1d2cc07d827561e  qemu-s390x-static
c71ac58f8749dc5334fc85d92ffb1bb41e54ebb143b7a79e9eac95d7efe283ca  qemu-riscv64-static
EOF
