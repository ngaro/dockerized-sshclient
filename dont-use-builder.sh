#!/usr/bin/env sh
echo "You probably don't want to use this image directly or as a base image."
echo ""
echo "It's a alpine with:"
echo " - a self-compiled static version of ssh, openssl and zlib."
echo " - the source code of the above both unextracted and extracted."
echo " - all packages needed to download and compile the above."
echo " - a script that downloads, compiles and installs the above."
echo ""
echo "You should only use this image to copy the ssh binary from"
echo ""
echo "If you wanted to use the alpine version of ssh, you should use 'garo/openssh-client:alpine' instead."