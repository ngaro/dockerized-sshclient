#!/usr/bin/env bash

ZLIB_VERSION=1.3.1
OPENSSL_VERSION=3.2.0
OPENSSH_VERSION=V_9_6_P1

prefix="/opt/openssh" # Installation directory of OpenSSH
top="$(pwd)"          # Directory where we will download and compile everything (current directory)
root="$top/root"      # Subdirectory where we will install everything.
build="$top/build"    # Subdirectory where we will compile everything.
dist="$top/dist"      # Subdirectory where we will download everything.

ZLIB_DIR="zlib-${ZLIB_VERSION}"
ZLIB_TGZ="$ZLIB_DIR.tar.gz"
ZLIB_URL="https://zlib.net/${ZLIB_TGZ}"
ZLIB_CHECKFILE="lib/libz.a"
ZLIB_BUILD_COMMANDS="./configure --prefix=\"$root\" --static && make && make install"   # Build in static mode so that we can link statically with OpenSSH

OPENSSL_DIR="openssl-${OPENSSL_VERSION}"
OPENSSL_TGZ="$OPENSSL_DIR.tar.gz"
OPENSSL_URL="https://www.openssl.org/source/${OPENSSL_TGZ}"
OPENSSL_CHECKFILE="bin/openssl"
OPENSSL_BUILD_COMMANDS="./config --prefix=\"$root\" no-shared no-tests && make && make install"  # Build in static mode so that we can link statically with OpenSSH

OPENSSH_DIR="openssh-portable-${OPENSSH_VERSION}"
OPENSSH_TGZ="$OPENSSH_DIR.tar.gz"
OPENSSH_URL="https://github.com/openssh/openssh-portable/archive/refs/tags/${OPENSSH_VERSION}.tar.gz"
OPENSSH_CHECKFILE="ssh"
OPENSSH_BUILD_COMMANDS="true"

export "CPPFLAGS=-I$root/include -L. -fPIC"; export "CFLAGS=$CPPFLAGS" # Compiler will look for headers in $root/include, libraries in the current directory, and generate position-independent code
export "LDFLAGS=-L$root/lib -L$root/lib64" # Compiler will look for libraries in $root/lib and $root/lib64

set -uex    # Show each command before executing it and exits when a command returns a non-zero exit code or a variable is used without being set
umask 0077  # Make sure that no one except the owner can read, write, or execute newly created files

#COMMENT THIS for debugging the script. Each stage will cache download and build
#rm -rf "$root" "$build" "$dist"
mkdir -p "$root" "$build" "$dist" # Create directories if they don't exis

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

build "ZLIB" "$ZLIB_VERSION" "$ZLIB_DIR" "$ZLIB_TGZ" "$ZLIB_URL" "$ZLIB_CHECKFILE" "$ZLIB_BUILD_COMMANDS"
build "OpenSSL" "$OPENSSL_VERSION" "$OPENSSL_DIR" "$OPENSSL_TGZ" "$OPENSSL_URL" "$OPENSSL_CHECKFILE" "$OPENSSL_BUILD_COMMANDS"
build "OpenSSH" "$OPENSSH_VERSION" "$OPENSSH_DIR" "$OPENSSH_TGZ" "$OPENSSH_URL" "$OPENSSH_CHECKFILE" "$OPENSSH_BUILD_COMMANDS"

cd "$build"/$OPENSSH_DIR
for libdir in lib ; do cp -p $root/$libdir/*.a . ; done # Copy all the static libraries to the openssh source directory so that we can link statically with them
#for libdir in lib lib64; do cp -p $root/$libdir/*.a . ; done # Copy all the static libraries to the openssh source directory so that we can link statically with them
if [ ! -f sshd_config.orig ]; then cp -p sshd_config sshd_config.orig; fi # Backup the original configuration file if we didn't do it yet
sed \
   -e 's/^#\(PubkeyAuthentication\) .*/\1 yes/' \
   -e '/^# *Kerberos/d' \
   -e '/^# *GSSAPI/d' \
   -e 's/^#\([A-Za-z]*Authentication\) .*/\1 no/' \
   sshd_config.orig > sshd_config # Change some settings in the server configuration file
export PATH=$root/bin:$PATH # Make sure that the binaries will be found when not using an absolute path
autoreconf || { echo "autoreconf failed"; exit 1; } # Generate the configure script
./configure LIBS="-lpthread" "--prefix=$root" "--exec-prefix=$root" --with-privsep-user=nobody --with-privsep-path="$prefix/var/empty" "--with-ssl-dir=$root" || { echo "configure failed"; exit 1; } # Configure the source code
make || { echo "make failed"; exit 1; } # Compile the source code
cd "$top"
