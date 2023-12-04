#!/bin/bash
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
"${SCRIPT_DIR}/../../RedUnit/red-063-linux" "${SCRIPT_DIR}/includeAllTests.red"
