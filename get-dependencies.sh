#!/bin/sh

set -eu

ARCH=$(uname -m)

echo "Installing package dependencies..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm \
    cmake         \
    fmt           \
    libzip        \
    lsb-release   \
    nlohmann-json \
    python        \
    sdl2_net      \
    spdlog        \
    tinyxml2

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
get-debloated-pkgs --add-common --prefer-nano libdecor-mini

# Comment this out if you need an AUR package
make-aur-package zenity-rs-bin

# If the application needs to be manually built that has to be done down here
echo "Making stable build of PaperBoat..."
echo "---------------------------------------------------------------"
REPO="https://github.com/HarbourMasters/PaperBoat"
VERSION="$(git ls-remote --tags --refs --sort=-v:refname "$REPO" | awk -F'/' '{print $NF; exit}')"
git clone --branch "$VERSION" --single-branch --recursive --depth 1 "$REPO" ./PaperBoat
echo "$VERSION" > ~/version

mkdir -p ./AppDir/bin
cd ./PaperBoat
patch -Np1 -i ../patches/001-paperboat-config-path.patch

cmake -S . -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build --config Release -j"$(nproc)"
cmake --build build --config Release --target GeneratePortO2R -j"$(nproc)"

mv -v build/Paperboat build/assets build/config.yml build/paperboat.o2r ../AppDir/bin
wget -O ../AppDir/bin/gamecontrollerdb.txt https://raw.githubusercontent.com/mdqinc/SDL_GameControllerDB/master/gamecontrollerdb.txt
