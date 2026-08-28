#!/bin/bash
# SUN Tech Unlimited - Game Grid  (macOS)
#
# Double-click this file. If macOS refuses to open it, see the
# "Security warning" section in README.txt on this drive.

cd "$(dirname "$0")" || exit 1

NODE_VER="v22.22.0"
case "$(uname -m)" in
  arm64) NARCH="arm64" ;;
  *)     NARCH="x64"   ;;
esac

BUNDLED="system/runtime/darwin-$NARCH/node"
FALLBACK_DIR="${TMPDIR:-/tmp}/suntech-game-grid/node-$NARCH"
NODE=""

printf '\n   SUN TECH UNLIMITED  ///  GAME GRID\n'
printf '   ----------------------------------------------\n'

# ---------------------------------------------------------------------------
# Find something that can run the loader.
# ---------------------------------------------------------------------------
find_node() {
  if [ -f "$BUNDLED" ]; then
    chmod +x "$BUNDLED" 2>/dev/null
    if "$BUNDLED" -v >/dev/null 2>&1; then
      NODE="$BUNDLED"; echo "   Using the copy of Node on this drive."; return 0
    fi
  fi
  if command -v node >/dev/null 2>&1; then
    NODE="node"; echo "   Using the Node already installed on this Mac."; return 0
  fi
  if [ -x "$FALLBACK_DIR/node" ] && "$FALLBACK_DIR/node" -v >/dev/null 2>&1; then
    NODE="$FALLBACK_DIR/node"; echo "   Using the Node saved on this Mac earlier."; return 0
  fi
  return 1
}

# ---------------------------------------------------------------------------
# Nothing found. Unlike Windows - which can fall back to PowerShell - macOS has
# no built-in web server we can rely on, so the loader genuinely needs Node.
# Rather than dead-ending, offer to fetch the official build automatically.
# ---------------------------------------------------------------------------
fetch_node() {
  local url="https://nodejs.org/dist/${NODE_VER}/node-${NODE_VER}-darwin-${NARCH}.tar.gz"
  local tmp; tmp="$(mktemp -d)" || return 1

  printf '   Downloading Node (about 50 MB, one time only) ...\n\n'
  if ! curl -fL --connect-timeout 15 --progress-bar "$url" -o "$tmp/node.tar.gz"; then
    rm -rf "$tmp"; return 1
  fi
  if ! tar -xzf "$tmp/node.tar.gz" -C "$tmp" 2>/dev/null; then
    rm -rf "$tmp"; return 1
  fi

  local src="$tmp/node-${NODE_VER}-darwin-${NARCH}/bin/node"
  [ -f "$src" ] || { rm -rf "$tmp"; return 1; }

  # Prefer the drive, so the next Mac gets it for free. Fall back to this
  # Mac's temp folder if the drive is full, read-only, or write-protected.
  if mkdir -p "system/runtime/darwin-$NARCH" 2>/dev/null && cp "$src" "$BUNDLED" 2>/dev/null; then
    chmod +x "$BUNDLED"; NODE="$BUNDLED"
    printf '\n   Saved onto the drive - every Mac from here will start straight away.\n'
  elif mkdir -p "$FALLBACK_DIR" 2>/dev/null && cp "$src" "$FALLBACK_DIR/node" 2>/dev/null; then
    chmod +x "$FALLBACK_DIR/node"; NODE="$FALLBACK_DIR/node"
    printf '\n   The drive is not writable, so it was saved on this Mac instead.\n'
  else
    rm -rf "$tmp"; return 1
  fi

  rm -rf "$tmp"
  return 0
}

if ! find_node; then
  cat <<'EOF'

   Node is not on this drive and not installed on this Mac.

   The loader needs it to run. (On Windows it can fall back to
   PowerShell, but macOS has no equivalent built in.)

EOF
  printf '   Download it now? About 50 MB, one time only. [Y/n] '
  read -r REPLY
  case "$REPLY" in
    [Nn]*)
      cat <<'EOF'

   ------------------------------------------------------------
   Stopped. To set the drive up later, run

       setup-runtime.command

   on a Mac with internet - once - and it will work everywhere
   after that. Or install Node yourself from https://nodejs.org
   ------------------------------------------------------------

EOF
      read -r -p "   Press Return to close. " _
      exit 1 ;;
  esac

  if ! fetch_node; then
    cat <<'EOF'

   ------------------------------------------------------------
   The download did not finish.

   Check this Mac's internet connection, and that nodejs.org is
   not blocked by a school or office network.

   You can also do it by hand:
     1. Go to https://nodejs.org and install the LTS version
     2. Double-click START.command again
   ------------------------------------------------------------

EOF
    read -r -p "   Press Return to close. " _
    exit 1
  fi
fi

printf '\n   Leave this window open while you play.\n'
"$NODE" system/server.js

printf '\n   The Game Grid has shut down.\n'
sleep 2
