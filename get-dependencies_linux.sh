#!/bin/bash

# USAGE:
# Execute get-dependencies_linux.sh with 1-2 parameters
# 1.) Specify one of the supported linux distros: ("ubuntu", "fedora", "alpine", "archlinux") REQUIRED
# 2.) Specify a mode: ("build-all" (default), "build-dependencies") OPTIONAL
#
# Example:
#  get-dependencies_linux.sh ubuntu build-all
#

set -e

if [ -z "$1" ]; then
  echo "get-dependencies_linux.sh requires an argument specifying a linux distro: (\"ubuntu\", \"fedora\", \"alpine\", \"archlinux\", \"opensuse-tumbleweed\")"
  exit 1
fi
DISTRO="$1"
if ! [[ "$1" =~ ^(ubuntu|fedora|alpine|archlinux|opensuse-tumbleweed)$ ]]; then
  echo "This script does not currently support Linux distro (${DISTRO}). Please see the documentation."
  exit 1
fi

MODE="build-all"
if [ -n "$2" ]; then
  if ! [[ "$2" =~ ^(build-all|build-dependencies)$ ]]; then
    echo "get-dependencies_linux.sh supports the following build modes: (\"build-all\", \"build-dependencies\")"
    exit 1
  fi
  MODE="$2"
fi

##################
# Ubuntu
##################
# Package search: https://packages.ubuntu.com/search

if [ "${DISTRO}" == "ubuntu" ]; then

  # Get Ubuntu version
  VERSION=$(grep -oP '(?<=^VERSION_ID=).+' /etc/os-release | tr -d '"')
  echo "Detected OS version: ${VERSION}"

  # Split version into parts
  VERSION_PARTS=( ${VERSION//./ } )

  echo "apt-get -u update"
  apt-get -u update

  if [ "${MODE}" == "build-all" ]; then
    echo "Installing build-all for Ubuntu"
    DEBIAN_FRONTEND=noninteractive apt-get -y install gcc g++ libc-dev dpkg-dev ninja-build pkg-config
  fi

  if [ "${VERSION_PARTS[0]}" -eq "18" ]; then
    echo "Installing build-dependencies for Ubuntu 18.x"
    DEBIAN_FRONTEND=noninteractive apt-get -y install cmake git zip unzip gettext asciidoctor libsdl2-dev libphysfs-dev libpng-dev libopenal-dev libvorbis-dev libogg-dev libopus-dev libtheora-dev libxrandr-dev libfreetype6-dev libfribidi-dev libharfbuzz-dev libcurl4-gnutls-dev gnutls-dev libsodium-dev libsqlite3-dev libprotobuf-dev protobuf-compiler libzip-dev
  elif [ "${VERSION_PARTS[0]}" -ge "20" ]; then
    echo "Installing build-dependencies for Ubuntu 20.x+"
    DEBIAN_FRONTEND=noninteractive apt-get -y install cmake git zip unzip gettext asciidoctor libsdl2-dev libphysfs-dev libpng-dev libopenal-dev libvorbis-dev libogg-dev libopus-dev libtheora-dev libxrandr-dev libfreetype-dev libfribidi-dev libharfbuzz-dev libcurl4-gnutls-dev gnutls-dev libsodium-dev libsqlite3-dev libprotobuf-dev protobuf-compiler libzip-dev
  else
    echo "Script does not currently support Ubuntu ${VERSION_PARTS[0]} (${VERSION})"
    exit 1
  fi

  # Required because of broken CMake config files installed by libzip-dev:
  DEBIAN_FRONTEND=noninteractive apt-get -y install zipcmp zipmerge ziptool
fi

##################
# Fedora
##################
# Package search: https://packages.fedoraproject.org/search

if [ "${DISTRO}" == "fedora" ]; then

  echo "dnf -y update"
  dnf -y update

  if [ "${MODE}" == "build-all" ]; then
    echo "Installing build-all for Fedora"
    dnf -y install gcc gcc-c++ ninja-build
  fi

  echo "Installing build-dependencies for Fedora"
  dnf -y install cmake git p7zip gettext rubygem-asciidoctor SDL2-devel physfs-devel libpng-devel openal-soft-devel libvorbis-devel libogg-devel opus-devel libtheora-devel freetype-devel fribidi-devel harfbuzz-devel libcurl-devel libsodium-devel sqlite-devel protobuf-devel libzip-devel
  # Required because of broken CMake config files installed by libzip-dev:
  dnf -y install libzip-tools
  dnf -y install vulkan-devel glslc
fi

##################
# Alpine
##################
# Package search: https://pkgs.alpinelinux.org/packages

if [ "${DISTRO}" == "alpine" ]; then

  if [ "${MODE}" == "build-all" ]; then
    echo "Installing build-all for Alpine"
    apk add --no-cache build-base ninja gdb
  fi

  echo "Installing build-dependencies for Alpine"
  apk add --no-cache cmake git p7zip gettext asciidoctor sdl2-dev physfs-dev libpng-dev openal-soft-dev libvorbis-dev libogg-dev opus-dev libtheora-dev freetype-dev fribidi-dev harfbuzz-dev curl-dev libsodium-dev sqlite-dev protobuf-dev libzip-dev
fi

##################
# ArchLinux
##################
# Package search: https://archlinux.org/packages/

if [ "${DISTRO}" == "archlinux" ]; then

  if [ "${MODE}" == "build-all" ]; then
    echo "Installing build-all for ArchLinux"
    pacman -S --noconfirm base-devel ninja gdb
  fi

  echo "Installing build-dependencies for ArchLinux"
  pacman -S --noconfirm cmake git p7zip gettext asciidoctor sdl2 physfs libpng openal libvorbis libogg opus libtheora xorg-xrandr freetype2 fribidi harfbuzz curl libsodium sqlite protobuf libzip
fi

##################
# OpenSUSE Tumbleweed
##################
# Package search: https://software.opensuse.org/search

if [ "${DISTRO}" == "opensuse-tumbleweed" ]; then

  if [ "${MODE}" == "build-all" ]; then
    echo "Installing build-all for OpenSUSE Tumbleweed"
    zypper install -y gcc-c++ libc++-devel ninja pkgconf-pkg-config cmake zip git libcurl-devel
  fi

  echo "Installing build-dependencies for OpenSUSE Tumbleweed"
  zypper install -y libSDL2-devel libphysfs-devel libpng16-devel libtheora-devel libvorbis-devel libogg-devel libopus-devel freetype-devel fribidi-devel harfbuzz-devel openal-soft-devel libsodium-devel sqlite3-devel libzip-devel libtinygettext0 ruby3.0-rubygem-asciidoctor vulkan-devel protobuf-devel
fi
##################

echo "get-dependencies_linux.sh: Done."
