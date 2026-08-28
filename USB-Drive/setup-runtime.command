#!/bin/bash
# SUN Tech Unlimited - one-time setup (macOS)
# Copies Node onto the drive so the Game Grid runs on any Mac.
# Run this ONCE, on a Mac with internet.

cd "$(dirname "$0")" || exit 1
NODE_VER="v22.22.0"

cat <<EOF

   SUN TECH UNLIMITED  ///  ONE-TIME SETUP
   ==============================================

   This copies Node onto the drive so the Game Grid works on Macs
   that have nothing installed.

   You only need to run this ONCE, on a Mac with internet. It pulls
   both Apple Silicon and Intel builds (about 100 MB) so the drive
   works on either kind of Mac. Nothing is installed on this Mac.

EOF
read -r -p "   Press Return to continue, or Ctrl-C to stop. " _

fetch_one() {
  local arch="$1" dest="$2"
  local url="https://nodejs.org/dist/${NODE_VER}/node-${NODE_VER}-darwin-${arch}.tar.gz"
  local tmp; tmp="$(mktemp -d)"

  printf '\n   Downloading %s build ...\n' "$arch"
  if ! curl -fL --progress-bar "$url" -o "$tmp/node.tar.gz"; then
    echo "   Download failed for $arch."
    rm -rf "$tmp"; return 1
  fi

  echo "   Unpacking $arch ..."
  tar -xzf "$tmp/node.tar.gz" -C "$tmp" || { rm -rf "$tmp"; return 1; }

  mkdir -p "$dest"
  cp "$tmp/node-${NODE_VER}-darwin-${arch}/bin/node" "$dest/node" || { rm -rf "$tmp"; return 1; }
  chmod +x "$dest/node"
  rm -rf "$tmp"
  echo "   $arch done."
}

ok=0
fetch_one arm64 "system/runtime/darwin-arm64" && ok=$((ok+1))
fetch_one x64   "system/runtime/darwin-x64"   && ok=$((ok+1))

# Make sure the launchers are executable, which matters if the drive was
# formatted somewhere that keeps permission bits.
chmod +x START.command setup-runtime.command 2>/dev/null

echo
if [ "$ok" -eq 2 ]; then
  cat <<'EOF'
   ----------------------------------------------------------
   Done. Node is on the drive for both kinds of Mac.

   Double-click START.command to try it.
   ----------------------------------------------------------
EOF
elif [ "$ok" -eq 1 ]; then
  cat <<'EOF'
   ----------------------------------------------------------
   Only one of the two builds downloaded. The drive will work
   on that kind of Mac. Run this again on a machine with a
   working connection to get the other.
   ----------------------------------------------------------
EOF
else
  cat <<EOF
   ----------------------------------------------------------
   Setup could not finish. Check this Mac's internet connection
   and that nodejs.org is not blocked, then run it again.

   By hand:
     1. Go to  https://nodejs.org/dist/${NODE_VER}/
     2. Download node-${NODE_VER}-darwin-arm64.tar.gz
     3. Open it, go into bin/, and copy the file called "node"
        into  system/runtime/darwin-arm64/  on this drive
   ----------------------------------------------------------
EOF
fi
echo
read -r -p "   Press Return to close. " _
