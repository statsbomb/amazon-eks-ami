#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

if [ "$#" -ne 1 ]; then
  echo >&2 "usage: $0 ROOT_DIR"
  exit 1
fi

ROOT_DIR="$1"

CHECK_ONLY="${CHECK_ONLY:-false}"
if [ "$CHECK_ONLY" = "true" ]; then
  if ! grep -l -E ' +$' -R --exclude-dir="$ROOT_DIR/.git" "$ROOT_DIR"; then
    exit 0
  else
    exit 1
  fi
fi

OS=$(uname)
for FILE in $(find "$ROOT_DIR" -type f -not -path "*/.git/*"); do
  if [ "$OS" = "Darwin" ]; then
    sed 's/[[:space:]]*$//g' "$FILE" > "$FILE.tmp"
    # macOS' chmod doesn't support '--reference' :')
    chmod "$(stat -f "%Mp%Lp" $FILE)" "$FILE.tmp"
    mv "$FILE.tmp" "$FILE"
  else
    # assume we're on Linux or another OS with a sane sed
    sed -i 's/[[:space:]]*$//g' "$FILE"
  fi
done
