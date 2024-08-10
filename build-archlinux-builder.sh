#!/usr/bin/env sh
export IMAGENAME="garo/archlinux"   # Name of the image to build
export ARCHIMAGETAG=base # Type of image to build (base / base-devel / base-multilib-devel )

# Check if docker is installed
docker --version || { echo "Docker is not installed"; exit 1; }

# Fetch a official Arch Linux image, rename and start it
docker pull archlinux || { echo "Failed to pull 'archlinux'"; exit 1; }
docker tag archlinux archlinuxbuilder || { echo "Failed to give 'archlinux' the extra name 'archlinuxbuilder'"; exit 1; }
docker rmi archlinux || { echo "Failed to forget the old name 'archlinux'"; exit 1; }
docker run -d --rm -v /var/run/docker.sock:/var/run/docker.sock --name archlinuxbuilder archlinuxbuilder sleep infinity || { echo "Failed to run 'archlinuxbuilder'"; exit 1; }

# Copy the build script to the running container and build archlinux/archlinux:${ARCHIMAGETAG} image
docker cp build-archlinux.sh archlinuxbuilder:/root/build-archlinux.sh || { echo "Failed to copy 'build-archlinux.sh' to 'archlinuxbuilder'"; exit 1; }
docker exec archlinuxbuilder /root/build-archlinux.sh ${ARCHIMAGETAG} || { echo "Failed to run 'build-archlinux.sh to build the '${ARCHIMAGETAG}' image of archlinux"; exit 1; }

# Stop and remove the builder
docker stop archlinuxbuilder || { echo "Failed to stop and remove 'archlinuxbuilder'"; exit 1; }
sleep 20 # Give the container some time to stop
docker rmi archlinuxbuilder || { echo "Failed to remove 'archlinuxbuilder'"; exit 1; }

# Rename the built image to $IMAGENAME:$ARCHIMAGETAG
docker tag archlinux/archlinux:${ARCHIMAGETAG} ${IMAGENAME}:${ARCHIMAGETAG} || { echo "Failed to give 'archlinux/archlinux:${ARCHIMAGETAG}' the extra name '${IMAGENAME}:${ARCHIMAGETAG}'"; exit 1; }
docker image prune || { echo "Failed to remove dangling images"; exit 1; }

echo "Success. archlinux/archlinux:${ARCHIMAGETAG} has been built and renamed to ${IMAGENAME}:${ARCHIMAGETAG} and the builder has been removed"
