#!/bin/bash
# Publishes a WinDjView-UA release to SourceForge (project windjview-ua) over SFTP.
# usage: installer/publish-sourceforge.sh <version> [--announce]
#   uploads installer/dist/WinDjView-UA-<version>-Setup.exe and SHA256SUMS.txt to Files/<version>/;
#   with --announce also uploads sourceforge/htdocs/index.html and version.txt to the project web,
#   which makes installed copies offer the update. version.txt must already contain <version>.
# Needs: SSH key registered at https://sourceforge.net/auth/shell_services
#   SF_USER (default gennadijkhimij), SF_KEY (default ~/.ssh/sourceforge_ed25519)
set -euo pipefail
VERSION=${1:?usage: publish-sourceforge.sh <version> [--announce]}
ANNOUNCE=${2:-}
SF_USER=${SF_USER:-gennadijkhimij}
SF_KEY=${SF_KEY:-$HOME/.ssh/sourceforge_ed25519}
REPO=$(cd "$(dirname "$0")/.." && pwd)
DIST="$REPO/installer/dist"
SETUP="WinDjView-UA-$VERSION-Setup.exe"
SSH_OPTS=(-i "$SF_KEY" -o IdentitiesOnly=yes -o BatchMode=yes)

[ -f "$DIST/$SETUP" ] || { echo "missing $DIST/$SETUP (run installer/build-windows.ps1)"; exit 1; }
(cd "$DIST" && tr -d '\r' < SHA256SUMS.txt | sha256sum -c -)

sftp -b - "${SSH_OPTS[@]}" "$SF_USER@frs.sourceforge.net" <<EOF
-mkdir /home/frs/project/windjview-ua/$VERSION
cd /home/frs/project/windjview-ua/$VERSION
put "$DIST/$SETUP"
put "$DIST/SHA256SUMS.txt"
ls -l
EOF

if [ "$ANNOUNCE" = --announce ]; then
  grep -qx "$VERSION" <(tr -d '\r\n ' < "$REPO/version.txt"; echo) \
    || { echo "version.txt does not contain $VERSION"; exit 1; }
  sftp -b - "${SSH_OPTS[@]}" "$SF_USER@web.sourceforge.net" <<EOF
cd /home/project-web/windjview-ua/htdocs
put "$REPO/sourceforge/htdocs/index.html"
put "$REPO/version.txt"
EOF
  echo "announced: https://windjview-ua.sourceforge.io/version.txt -> $VERSION"
fi
echo "files: https://sourceforge.net/projects/windjview-ua/files/$VERSION/"
