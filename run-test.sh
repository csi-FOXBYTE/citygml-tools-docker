#!/usr/bin/env sh
set -eu

IMAGE="${IMAGE:-citygml-tools:min}"
SKIP_BUILD=0

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
TEST_DATA_PATH="${SCRIPT_DIR}/test_data"

while [ "$#" -gt 0 ]; do
  case "$1" in
    -s|--skip-build)
      SKIP_BUILD=1
      shift
      ;;
    --image)
      shift
      if [ "$#" -eq 0 ]; then
        echo "Error: --image expects a value." >&2
        exit 1
      fi
      IMAGE="$1"
      shift
      ;;
    --)
      shift
      break
      ;;
    *)
      break
      ;;
  esac
done

if [ ! -d "$TEST_DATA_PATH" ]; then
  echo "Error: Directory 'test_data' not found: $TEST_DATA_PATH" >&2
  exit 1
fi

if [ "$SKIP_BUILD" -eq 0 ]; then
  docker build -t "$IMAGE" .
fi

if [ "$#" -eq 0 ]; then
  set -- stats --no-json-report /data
fi

docker run --rm -v "${TEST_DATA_PATH}:/data:ro" "$IMAGE" "$@"
