#!/bin/bash
# SUN Tech Unlimited - Game Grid  (macOS)
# Double-click this file. If macOS says it can't be opened, right-click it
# and choose Open, then Open again - that only has to be done once.

cd "$(dirname "$0")" || exit 1

printf '\n   SUN TECH UNLIMITED  ///  GAME GRID\n'
printf '   ----------------------------------------------\n'
printf '   Starting up. Leave this window open while you play.\n\n'

ARCH="$(uname -m)"
case "$ARCH" in
  arm64) BUNDLED="system/runtime/darwin-arm64/node" ;;
  *)     BUNDLED="system/runtime/darwin-x64/node"   ;;
esac

if [ -x "$BUNDLED" ] || [ -f "$BUNDLED" ]; then
  echo "   Using the copy of Node on this drive."
  chmod +x "$BUNDLED" 2>/dev/null
  "$BUNDLED" system/server.js
elif command -v node >/dev/null 2>&1; then
  echo "   Using the Node already installed on this Mac."
  node system/server.js
else
  cat <<'EOF'

   ------------------------------------------------------------
   The Game Grid could not start - Node was not found.

   Ask whoever set this drive up to run  setup-runtime.command
   once on a Mac with internet. That copies Node onto the drive
   and this stops happening.

   Or install Node yourself from  https://nodejs.org
   ------------------------------------------------------------

EOF
  read -r -p "   Press Return to close. " _
  exit 1
fi

printf '\n   The Game Grid has shut down.\n'
sleep 2
