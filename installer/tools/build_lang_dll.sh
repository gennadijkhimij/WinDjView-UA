#!/bin/bash
# Build a resource-only WinDjView language DLL with MinGW-w64 (no MSVC/MFC needed).
# usage: build_lang_dll.sh <repo_windjview_dir> <Language dir name> <RC basename> <x86|x64> <AFX_TARG macro> <out.dll>
# Needs: mingw-w64 (windres, gcc), python3.
# Differences from the MSVC build (Languages\<Lang>\*.vcxproj), all handled below:
#  * afxres.rc / afxprint.rc (standard MFC resources) are not available -> tools/afx_extra.rc + Ukrainian MFC strings are used
#  * windres writes TOOLBAR resources in a layout MFC cannot read (32-bit ids) -> tools/fix_toolbar.py writes RT_TOOLBAR in rc.exe layout
set -euo pipefail
SRC=$1; LANGDIR=$2; RCNAME=$3; ARCH=$4; TARG=$5; OUT=$6
TOOLS=$(cd "$(dirname "$0")" && pwd)
T=$(mktemp -d)
mkdir -p "$T/Languages/$LANGDIR"
cp -r "$SRC/res" "$T/res"
cp "$SRC/Languages/$LANGDIR/resource.h" "$T/Languages/$LANGDIR/"
cp "$TOOLS/afxres.h" "$T/Languages/$LANGDIR/afxres.h"
cp -r "$TOOLS/afx_res" "$T/Languages/$LANGDIR/afx_res"
python3 - "$SRC/Languages/$LANGDIR/$RCNAME" "$T/Languages/$LANGDIR/t.rc" "$TOOLS" <<'PY'
import sys
b=open(sys.argv[1],'rb').read(); out=[]
for l in b.replace(b'\r\n',b'\n').split(b'\n'):
    if b'..\\' in l and b'\\r\\n' not in l:
        l=l.replace(b'\\\\',b'/').replace(b'\\',b'/')          # Windows paths -> POSIX
    if (b'afxres.rc' in l or b'afxprint.rc' in l) and b'\\r\\n' not in l:
        l=b'// '+l                                              # MSVC-only MFC boilerplate
    out.append(l)
open(sys.argv[2],'wb').write(b'\n'.join(out))
PY
cd "$T/Languages/$LANGDIR"
TOOLBAR_LANG="LANGUAGE 0x22, 0x01" python3 "$TOOLS/fix_toolbar.py" t.rc t2.rc . resource.h afxres.h
cat "$TOOLS/afx_extra.rc" >> t2.rc
if [ "$LANGDIR" = Ukrainian ]; then
  python3 - "$TOOLS" >> t2.rc <<'PY'
import sys; sys.path.insert(0, sys.argv[1])
from afx_strings_uk import UK
lines = ['', 'LANGUAGE 0x22, 0x01', 'STRINGTABLE', 'BEGIN']
for k in sorted(UK): lines.append('    %d "%s"' % (k, UK[k].replace('"', '""').replace('\n', '\\n')))
lines.append('END')
sys.stdout.buffer.write(('\n'.join(lines) + '\n').encode('cp1251'))
PY
fi
if [ "$ARCH" = x64 ]; then P=x86_64-w64-mingw32; F=pe-x86-64; else P=i686-w64-mingw32; F=pe-i386; fi
$P-windres -F $F -I. -DAFX_RESOURCE_DLL -D$TARG -DNDEBUG -i t2.rc -o t.o
$P-gcc -shared -nostdlib -Wl,--entry=0 -Wl,--no-seh -Wl,--dynamicbase -o out.dll t.o
cp out.dll "$OUT"
cd / && rm -rf "$T"
echo "built $OUT"
