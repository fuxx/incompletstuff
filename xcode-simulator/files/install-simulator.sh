#!/bin/sh

set -eo pipefail
shopt -s nullglob

expand_dmg() {
    declare dmg="$1" target="${2:-/}"
    echo "Expanding $dmg..."
    TMPMOUNT=`/usr/bin/mktemp -d /tmp/dmg.XXXX`
    TMPTARGET=`/usr/bin/mktemp -d /tmp/target.XXXX`
    hdiutil attach "$dmg" -mountpoint "$TMPMOUNT"
    find "$TMPMOUNT" -name '*.pkg' -exec pkgutil --expand "{}" "$TMPTARGET/data" \;
    tar zxf "$TMPTARGET/data/Payload" -C "$target"
    hdiutil detach "$TMPMOUNT"
    rm -rf "$TMPMOUNT"
    rm -rf "$TMPTARGET"
    rm -f "$dmg"
}

expand_dmg_url() {
    declare url="$1" target="$2"
    dmg=$(basename "$url")
    echo "Downloading $url..."
    curl --retry 3 -o "$dmg" "$url"
    expand_dmg "$dmg" "$target"
}

# Install Simulators
install_simulator() {
  INSTALL_PATH="/Library/Developer/CoreSimulator/Profiles/Runtimes/iOS $1.simruntime"
  if [ -d "$INSTALL_PATH" ]; then
      echo "Already installed"
      exit 0
  fi
  sudo mkdir -p /Library/Developer/CoreSimulator/Profiles/Runtimes/iOS\ $1.simruntime
  expand_dmg_url \
      https://devimages-cdn.apple.com/downloads/xcode/simulators/com.apple.pkg.iPhoneSimulatorSDK$2 \
      /Library/Developer/CoreSimulator/Profiles/Runtimes/iOS\ $1.simruntime
}

install_simulator $1 $2
