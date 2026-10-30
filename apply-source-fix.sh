#!/usr/bin/env bash
set -euo pipefail

PATCH_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="${1:-}"

if [[ -z "$PROJECT_DIR" || ! -d "$PROJECT_DIR" ]]; then
  echo "Usage: bash apply-source-fix.sh /path/to/nexus_build" >&2
  exit 2
fi
PROJECT_DIR="$(cd -- "$PROJECT_DIR" && pwd)"

for required in \
  "src/client/java/com/aegis/client/AegisClient.java" \
  "src/client/java/com/aegis/client/gui/AegisMenuScreen.java" \
  "src/main/java/com/aegis/client/core/ClickTracker.java" \
  "src/main/resources/fabric.mod.json"; do
  if [[ ! -f "$PATCH_DIR/$required" ]]; then
    echo "Patch is incomplete: missing $required" >&2
    exit 1
  fi
done

mkdir -p "$PROJECT_DIR/src"
cp -a "$PATCH_DIR/src/." "$PROJECT_DIR/src/"

EMBEDDED="$PROJECT_DIR/packaging/AppDir/usr/share/aegis/project"
if [[ -d "$EMBEDDED" && -d "$PATCH_DIR/packaging/AppDir/usr/share/aegis/project/src" ]]; then
  mkdir -p "$EMBEDDED/src"
  cp -a "$PATCH_DIR/packaging/AppDir/usr/share/aegis/project/src/." "$EMBEDDED/src/"
fi

# These are obsolete in the new 26.1 input API and must not remain as source files.
rm -f \
  "$PROJECT_DIR/src/client/java/com/aegis/client/mixin/MouseMixin.java" \
  "$PROJECT_DIR/src/main/resources/aegis.client.mixins.json" \
  "$EMBEDDED/src/client/java/com/aegis/client/mixin/MouseMixin.java" \
  "$EMBEDDED/src/main/resources/aegis.client.mixins.json"

rmdir "$PROJECT_DIR/src/client/java/com/aegis/client/mixin" 2>/dev/null || true
rmdir "$EMBEDDED/src/client/java/com/aegis/client/mixin" 2>/dev/null || true

echo "Aegis Minecraft 26.1.2 source patch applied to: $PROJECT_DIR"
echo "The existing .github/workflows/build.yml was not modified."
