#!/bin/bash
# Build plugin-dependencies.tar.gz locally (same steps as the CI workflow): a portable
# Python 3.13 runtime plus the OCR Python packages (rapidocr, onnxruntime, ...) that the
# plugin extracts at first start. The bundled Python itself installs the packages, so the
# wheels always match the runtime. Output: ./plugin-dependencies.tar.gz and its SHA256,
# which goes into package.json's remote_binary entry.
set -euo pipefail
cd "$(dirname "$(readlink -f "$0")")/.."

PY_URL="https://github.com/astral-sh/python-build-standalone/releases/download/20260408/cpython-3.13.13%2B20260408-x86_64-unknown-linux-gnu-install_only_stripped.tar.gz"
PY_SHA256="a1dbc39f9c7b7d4ff3074fa18de66714c4e4400643bd657894a65803b0362a92"
BUILD=dependencies_build

rm -rf "$BUILD" plugin-dependencies.tar.gz
mkdir -p "$BUILD/python313"

echo "== Python 3.13 portable runtime"
curl -fL --retry 3 -o "$BUILD/python313/python.tar.gz" "$PY_URL"
echo "$PY_SHA256  $BUILD/python313/python.tar.gz" | sha256sum -c -
tar -xzf "$BUILD/python313/python.tar.gz" -C "$BUILD/python313"
rm "$BUILD/python313/python.tar.gz"
PY="$PWD/$BUILD/python313/python/bin/python3"
"$PY" --version

echo "== Python packages"
"$PY" -m pip install -q --no-cache-dir -r requirements.txt -t "$BUILD/py_modules"
# evdev for Decky Loader's own Python 3.11 runtime (controller input in the backend)
"$PY" -m pip install -q --no-cache-dir evdev-binary -t "$BUILD/py_modules" \
    --python-version 3.11 --only-binary=:all: --platform manylinux_2_28_x86_64 --no-deps

echo "== Strip unneeded files"
(
    cd "$BUILD/py_modules"
    rm -rf sympy sympy-*.dist-info sympy-*.data isympy.py mpmath mpmath-*.dist-info \
        flatbuffers flatbuffers-*.dist-info protobuf-*.dist-info
    # rapidocr pulls in full opencv; only the headless build is needed
    rm -rf opencv_python.libs opencv_python-*.dist-info
    "$PY" -m pip install -q --no-cache-dir opencv-python-headless -t . --upgrade --force-reinstall --no-deps
    # the plugin downloads its own OCR models; rapidocr needs the (empty) folder to exist
    rm -rf rapidocr/models && mkdir -p rapidocr/models
    find . -type d \( -name tests -o -name test -o -name testing -o -name __pycache__ \) -prune -exec rm -rf {} +
    find . \( -name '*.pyc' -o -name '*.pyi' \) -delete
    rm -rf numpy/_pyinstaller onnxruntime/datasets
    echo "py_modules: $(du -sh . | cut -f1)"
)

echo "== Archive"
tar -C "$BUILD" -czf plugin-dependencies.tar.gz py_modules python313
ls -l plugin-dependencies.tar.gz
sha256sum plugin-dependencies.tar.gz
