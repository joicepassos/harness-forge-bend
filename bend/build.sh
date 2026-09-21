#!/bin/sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
PIN=75cb8f3e041aeaad2b37e726c0a33ba19dc49df8
TOOLCHAIN=${BEND_SOURCE:-"$ROOT/../.cache/bend"}
case "$(uname -s)" in
  Linux|Darwin) ;;
  *) echo 'This experiment targets Linux and macOS.' >&2; exit 1 ;;
esac
if [ ! -f "$TOOLCHAIN/bend2/main.ts" ]; then
  mkdir -p "$TOOLCHAIN"
  git -C "$TOOLCHAIN" init -q
  git -C "$TOOLCHAIN" remote add origin https://github.com/bendlang/bend.git
  git -C "$TOOLCHAIN" fetch --depth 1 origin "$PIN"
  git -C "$TOOLCHAIN" checkout --detach FETCH_HEAD
fi
ACTUAL=$(git -C "$TOOLCHAIN" rev-parse HEAD)
if [ "$ACTUAL" != "$PIN" ]; then
  echo "Expected Bend $PIN, found $ACTUAL" >&2
  exit 1
fi
TOOLCHAIN=$(CDPATH= cd -- "$TOOLCHAIN" && pwd)
mkdir -p "$ROOT/bin"
cd "$TOOLCHAIN/bend2"
bun main.ts "$ROOT/PROOF.bend"
bun main.ts "$ROOT/main.bend" --check-only
node --import "$TOOLCHAIN/bend2/main.ts" "$ROOT/test_core.mjs"
node --import "$TOOLCHAIN/bend2/main.ts" "$ROOT/test_harness.mjs"
python3 -m unittest discover -s "$ROOT" -p test_scan.py
bun main.ts "$ROOT/main.bend" -o "$ROOT/bin/harnessforge-bend-core"
python3 "$ROOT/test_integration.py"
printf '\nReady: python3 %s/scan.py /path/to/project\n' "$ROOT"
