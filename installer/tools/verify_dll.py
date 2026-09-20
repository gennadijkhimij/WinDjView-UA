#!/usr/bin/env python3
"""Sanity checks for a built WinDjViewUA.dll (guards against the mistakes found while porting):
  * all resources are in language 0x0422, VERSIONINFO has FileVersion == IDS_CURRENT_VERSION and Translation 0x0422
    (WinDjView only loads a language DLL whose FileVersion equals its own version);
  * RT_TOOLBAR resources use the layout MFC expects (windres would write 32-bit ids and MFC would crash);
  * the Ukrainian .rc defines every identifier the Russian reference .rc defines.
usage: verify_dll.py <repo root> <dll> [<dll> ...]"""
import re, struct, sys, os
import pefile

repo, dlls = sys.argv[1], sys.argv[2:]
lang_dir = os.path.join(repo, 'windjview', 'Languages')
errors = []

def rc_text(path):
    return open(path, 'rb').read().decode('cp1251', 'replace')

ua = rc_text(os.path.join(lang_dir, 'Ukrainian', 'WinDjViewUA.rc'))
ru = rc_text(os.path.join(lang_dir, 'Russian', 'WinDjViewRU.rc'))
version = re.search(r'IDS_CURRENT_VERSION\s+"([^"]+)"', ua).group(1)

# identifiers that start a line (string-table ids, control/menu ids, resource names)
IDENT = re.compile(r'^\s*(?:\w+\s+(?:DIALOGEX|DIALOG|MENU|TOOLBAR|ACCELERATORS)\b|((?:AFX_)?ID[A-Z]?_[A-Z0-9_]+|IDR_\w+))', re.M)
def idents(t):
    return {m.group(1) for m in IDENT.finditer(t) if m.group(1)} | set(re.findall(r'^(\w+)\s+(?:DIALOGEX|DIALOG|MENU|TOOLBAR|ACCELERATORS)\b', t, re.M))
missing = sorted(idents(ru) - idents(ua))
if missing:
    errors.append('identifiers present in the Russian .rc but missing in the Ukrainian one: %s' % ', '.join(missing[:20]))

for path in dlls:
    pe = pefile.PE(path, fast_load=True)
    pe.parse_data_directories([pefile.DIRECTORY_ENTRY['IMAGE_DIRECTORY_ENTRY_RESOURCE'],])
    langs, n = set(), 0
    for t in pe.DIRECTORY_ENTRY_RESOURCE.entries:
        for i in t.directory.entries:
            for l in i.directory.entries:
                langs.add(l.id); n += 1
                d = l.data.struct
                if t.id == 241:                                   # RT_TOOLBAR
                    data = pe.get_data(d.OffsetToData, d.Size)
                    ver, w, h, cnt = struct.unpack_from('<4H', data)
                    if ver != 1 or len(data) != 8 + 2 * cnt:
                        errors.append('%s: toolbar %s has a wrong layout' % (path, i.id))
    if langs != {0x422}:
        errors.append('%s: resource languages %s (expected only 0x422)' % (path, sorted(hex(x) for x in langs)))
    pe.parse_data_directories([pefile.DIRECTORY_ENTRY['IMAGE_DIRECTORY_ENTRY_RESOURCE']])
    fi = {}
    pe2 = pefile.PE(path)
    for fileinfo in getattr(pe2, 'FileInfo', []):
        for e in fileinfo:
            if e.Key == b'StringFileInfo':
                for st in e.StringTable:
                    fi.update({k.decode(): v.decode() for k, v in st.entries.items()})
            if e.Key == b'VarFileInfo':
                for v in e.Var:
                    if v.entry.get(b'Translation') is not None and v.entry[b'Translation'].strip() != '0x0422 0x0000':
                        errors.append('%s: Translation %s' % (path, v.entry[b'Translation']))
    if fi.get('FileVersion') != version:
        errors.append('%s: FileVersion %r != IDS_CURRENT_VERSION %r' % (path, fi.get('FileVersion'), version))
    print('%s: machine 0x%x, %d resources, FileVersion %s' % (path, pe.FILE_HEADER.Machine, n, fi.get('FileVersion')))

if errors:
    print('VERIFY FAILED:\n  ' + '\n  '.join(errors)); sys.exit(1)
print('verify OK')
