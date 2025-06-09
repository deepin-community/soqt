#!/bin/sh
set -e

# Environment setup
export OMPI_MCA_orte_rsh_agent=/bin/false
export DEB_HOST_MULTIARCH=$(dpkg-architecture -qDEB_HOST_MULTIARCH)
export XDG_RUNTIME_DIR="$AUTOPKGTEST_TMP/run"
mkdir -m 700 "$XDG_RUNTIME_DIR"

# Get the directory where test scripts/demos reside
TEST_DIR="$(dirname "$0")"

# Prepare workspace
cd "$AUTOPKGTEST_TMP"
mkdir src
cd src

# Copy all demo*.cpp files from the test directory
cp "$TEST_DIR"/demo*.cpp .

# Build and run each demo
for DEMO_SOURCE in demo*.cpp; do
  echo "=== Testing $DEMO_SOURCE ==="
  [ -f "$DEMO_SOURCE" ] || continue  # Skip if no files match

  EXECUTABLE="${DEMO_SOURCE%.cpp}"   # e.g., "demo1" for "demo1.cpp"

  g++ -o "$EXECUTABLE" "$DEMO_SOURCE" \
    -I /usr/include/Inventor/Qt \
    -I/usr/include/"${DEB_HOST_MULTIARCH}"/"qt${QT_VERSIOM}" \
    -I/usr/include/"${DEB_HOST_MULTIARCH}"/"qt${QT_VERSIOM}"/QtCore \
    -I/usr/include/"${DEB_HOST_MULTIARCH}"/"qt${QT_VERSIOM}"/QtWidgets \
    -fPIC -lSoQt -lCoin -lQt"${QT_VERSIOM}"Core -lQt"${QT_VERSIOM}"Widgets -lQt"${QT_VERSIOM}"Gui 

  [ -x "$EXECUTABLE" ] || { echo "Build failed for $DEMO_SOURCE"; exit 1; }
  xvfb-run "./$EXECUTABLE"
  echo "PASS: $DEMO_SOURCE"
done