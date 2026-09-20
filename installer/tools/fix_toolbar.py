#!/usr/bin/env python3
"""windres writes TOOLBAR resources with 32-bit item IDs, but MFC (CToolBar::LoadToolBar) expects the
rc.exe layout: WORD version=1, WORD width, WORD height, WORD count, WORD id[count] (SEPARATOR = 0).
This script replaces every `NAME TOOLBAR w, h BEGIN ... END` block in an .rc by a raw RT_TOOLBAR (241)
resource generated in the correct layout.
usage: fix_toolbar.py <in.rc> <out.rc> <outdir> <header.h> [<header.h> ...]"""
import re, struct, sys, os
src, dst, outdir, *hdrs = sys.argv[1:]
defs = {}
for h in hdrs:
    for m in re.finditer(rb'^\s*#\s*define\s+(\w+)\s+(0[xX][0-9A-Fa-f]+|\d+)\b', open(h, 'rb').read(), re.M):
        defs[m.group(1).decode()] = int(m.group(2), 0)
def val(tok):
    tok = tok.strip()
    return int(tok, 0) if re.fullmatch(r'0[xX][0-9A-Fa-f]+|\d+', tok) else defs[tok]
text = open(src, 'rb').read().decode('latin-1')
pat = re.compile(r'^(\w+)[ \t]+TOOLBAR[ \t]+(\d+)[ \t]*,[ \t]*(\d+)[ \t]*\r?\n[ \t]*BEGIN[ \t]*\r?\n(.*?)^[ \t]*END[ \t]*$', re.M | re.S)
extra = []
def repl(m):
    name, w, h, body = m.group(1), int(m.group(2)), int(m.group(3)), m.group(4)
    ids = []
    for line in body.splitlines():
        line = line.split('//')[0].strip()
        if not line: continue
        if line.upper().startswith('SEPARATOR'): ids.append(0)
        else:
            mm = re.fullmatch(r'BUTTON\s+(\w+)', line)
            assert mm, 'unexpected toolbar line: ' + line
            ids.append(val(mm.group(1)))
    data = struct.pack('<4H', 1, w, h, len(ids)) + b''.join(struct.pack('<H', i) for i in ids)
    fn = 'toolbar_%s.bin' % name
    open(os.path.join(outdir, fn), 'wb').write(data)
    extra.append('%d 241 "%s"' % (val(name), fn))
    return '// (TOOLBAR %s replaced by raw RT_TOOLBAR %s)' % (name, fn)
text2, n = pat.subn(repl, text)
assert n >= 1, 'no TOOLBAR blocks found'
lang = os.environ.get('TOOLBAR_LANG', '')   # e.g. 'LANGUAGE 0x22, 0x01' (must match the language of the .rc)
text2 += '\n' + (lang + '\n' if lang else '') + '\n'.join(extra) + '\n'
open(dst, 'wb').write(text2.encode('latin-1'))
print('toolbars converted:', n)
