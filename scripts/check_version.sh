#!/usr/bin/env bash
# Verify pubspec.yaml version is valid semver and matches CHANGELOG / optional VERSION.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PUBSPEC="$ROOT/pubspec.yaml"
CHANGELOG="$ROOT/CHANGELOG.md"
VERSION_FILE="$ROOT/VERSION"

version="$(sed -nE 's/^version:[[:space:]]*([0-9]+\.[0-9]+\.[0-9]+)(\+[0-9]+)?/\1/p' "$PUBSPEC" | head -1)"
if [[ -z "$version" ]]; then
  echo "error: could not parse version from pubspec.yaml" >&2
  exit 1
fi

if ! [[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "error: version '$version' is not MAJOR.MINOR.PATCH" >&2
  exit 1
fi

echo "pubspec version: $version"

if ! grep -qE "^## \[${version}\]" "$CHANGELOG"; then
  echo "error: CHANGELOG.md has no ## [$version] section" >&2
  exit 1
fi
echo "CHANGELOG has ## [$version]"

if [[ -f "$VERSION_FILE" ]]; then
  file_version="$(tr -d '[:space:]' < "$VERSION_FILE")"
  if [[ "$file_version" != "$version" ]]; then
    echo "error: VERSION ($file_version) does not match pubspec ($version)" >&2
    exit 1
  fi
  echo "VERSION file matches"
fi

if [[ "${1:-}" == "--expect-tag" ]]; then
  tag="${2:-}"
  if [[ -z "$tag" ]]; then
    echo "usage: $0 --expect-tag vX.Y.Z" >&2
    exit 1
  fi
  expected="${tag#v}"
  if [[ "$version" != "$expected" ]]; then
    echo "error: pubspec version ($version) does not match tag ($tag)" >&2
    exit 1
  fi
  echo "tag $tag matches pubspec"
fi
