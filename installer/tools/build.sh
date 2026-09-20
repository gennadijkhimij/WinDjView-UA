#!/bin/bash
# Builds the Ukrainian language DLLs (x64 + x86) with MinGW-w64 and the NSIS installers.
# Needs: mingw-w64 (x86_64-w64-mingw32-windres/gcc, i686-w64-mingw32-windres/gcc), nsis (makensis 3.x), python3 + pefile.
#   Ubuntu/Debian:  sudo apt-get install mingw-w64 nsis python3-pefile
# Result: installer/build/{x64,x86}/WinDjViewUA.dll and installer/dist/*.exe (+ SHA256SUMS.txt).
# The full installer is built only if the official 64-bit WinDjView.exe is in installer/bin/x64/ (see installer/bin/README.txt).
set -euo pipefail
HERE=$(cd "$(dirname "$0")" && pwd)
INST=$(dirname "$HERE")
REPO=$(dirname "$INST")
mkdir -p "$INST/build/x64" "$INST/build/x86" "$INST/dist"

for arch in x64 x86; do
  "$HERE/build_lang_dll.sh" "$REPO/windjview" Ukrainian WinDjViewUA.rc "$arch" AFX_TARG_UKR "$INST/build/$arch/WinDjViewUA.dll"
done
python3 "$HERE/verify_dll.py" "$REPO" "$INST/build/x64/WinDjViewUA.dll" "$INST/build/x86/WinDjViewUA.dll"

cd "$INST"
makensis -V2 WinDjView-UA-LangPack.nsi
if [ -f bin/x64/WinDjView.exe ]; then
  makensis -V2 WinDjView-Setup.nsi
else
  echo "NOTE: installer/bin/x64/WinDjView.exe not found - the full installer was skipped (only the language pack was built)."
fi
mv -f ./*.exe dist/
( cd dist && sha256sum ./*.exe > SHA256SUMS.txt && cat SHA256SUMS.txt )
