#!/usr/bin/env sh
ARCHIMAGETAG=$1
# Install the necessary packages to build the image
pacman -Syu --noconfirm make devtools git fakechroot fakeroot docker || { echo "Failed to install 'make', 'devtools', 'git', 'fakechroot', 'fakeroot', and 'docker'"; exit 1; }

# Clone the archlinux-docker repository in /root/archlinux-docker and go there
cd /root || { echo "Failed to go to '/root'"; exit 1; }
git clone https://gitlab.archlinux.org/archlinux/archlinux-docker.git || { echo "Failed to clone 'https://gitlab.archlinux.org/archlinux/archlinux-docker.git'"; exit 1; }
cd archlinux-docker || { echo "Failed to go to '/root/archlinux-docker'"; exit 1; }

# Change the OCI to use from 'podman' to 'docker' (because we know it better)
perl -pi -e 's/podman.*/docker/' Makefile || { echo "Failed to change the OCI to use from 'podman' to 'docker' in 'Makefile'"; exit 1; }

# Build the image
make image-${ARCHIMAGETAG} || { echo "Failed to make 'archlinux/archlinux:${ARCHIMAGETAG}'"; exit 1; }
echo "archlinux/archlinux:${ARCHIMAGETAG} has been built successfully"
