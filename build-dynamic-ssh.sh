#!/usr/bin/env sh

OPENSSH_VERSION=V_9_8_P1

top="$(pwd)"          # Directory where we will download and compile everything (current directory)
root="$top/rootdyn"      # Subdirectory where we will install everything.
build="$top/builddyn"    # Subdirectory where we will compile everything.
dist="$top/distdyn"      # Subdirectory where we will download everything.

OPENSSH_DIR="openssh-portable-${OPENSSH_VERSION}"
OPENSSH_TGZ="$OPENSSH_DIR.tar.gz"
OPENSSH_URL="https://github.com/openssh/openssh-portable/archive/refs/tags/${OPENSSH_VERSION}.tar.gz"
OPENSSH_CHECKFILE="bin/ssh"
#Make sure it ends up in $root/bin, that it drops privileges and that it should use the OpenSSL instead of the one that comes with the ssh source code
OPENSSH_BUILD_COMMANDS="autoreconf && ./configure --prefix=\"$root\" --exec-prefix=\"$root\" --with-privsep-user=nobody && make && make install"

read -p "We will be working in $top, things might get messy (t)here. Press Ctrl+C to cancel now or Enter to continue" ignorethisvariable

set -uex    # Show each command before executing it and exits when a command returns a non-zero exit code or a variable is used without being set
umask 0077  # Make sure that no one except the owner can read, write, or execute newly created files

export "CPPFLAGS=-I$root/include -L. -fPIC -pthread"; export "CFLAGS=$CPPFLAGS" # Compiler will look for headers in $root/include, libraries in the current directory and generate position-independent code and use pthreads

#Check if everything needed is available
#autoreconf --version || { echo "You still need to install autoconf"; exit 1; }
#aclocal --version || { echo "You still need to install automake"; exit 1; }
#curl --version || { echo "You still need to install curl"; exit 1; }
#perl -v || { echo "You still need to install perl"; exit 1; } # OpenSSL's ./configure needs perl
#make --version || { echo "You still need to install make"; exit 1; }
#gcc --version || { echo "You still need to install gcc"; exit 1; }
#[ -f /usr/include/linux/mman.h ] || { echo "You don't have the Linux kernel headers installed"; exit 1; }
#echo "#include <stdio.h>" | gcc -E - -o /dev/null || { echo "You still need to install the C library development files"; exit 1; }

mkdir -p "$root" "$build" "$dist" # Create directories if they don't exist

build() {
    local name="$1"; local version="$2"; local dir="$3"; local tgz="$4"; local url="$5"; local checkfile="$6"; local buildcommands="$7"
    if [ ! -f "$root/$checkfile" ]; then # Only skip this stage if we have already have a correctly $name $version
        echo "---- Building $name $version -----"
        rm -rf "$build/$dir" # Remove garbage from previous failed builds
        if [ ! -f "$dist/$tgz" ]; then # If we didn't download the source code yet
            curl --output $dist/$tgz --location $url  # Download the source code
        fi
        tar -C $build -xzf $dist/$tgz || { echo "Extracting $dist/$tgz failed, probably because the download failed"; exit 1; } # Extract the source code
        cd "$build"/$dir
        eval $buildcommands || { echo "Building $name $version failed"; exit 1; }
    else
        echo "---- We already have $name $version -----"
    fi
    cd "$top"
}

build "OpenSSH" "$OPENSSH_VERSION" "$OPENSSH_DIR" "$OPENSSH_TGZ" "$OPENSSH_URL" "$OPENSSH_CHECKFILE" "$OPENSSH_BUILD_COMMANDS"

echo "Everything done. You can find the dynamically linked OpenSSH binaries in $root/bin"
