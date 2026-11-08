#!/usr/bin/env bash
# Configuration guidée du dashboard. Lance-le une fois après le clonage.
set -e

cd "$(dirname "$0")"

echo "Dashboard : configuration"
echo "Laisse vide si tu ne veux pas utiliser Spotify (le dashboard affichera alors les citations)."
echo

read -r -p "Clé API Last.fm (https://www.last.fm/api/account/create) : " LASTFM_KEY
read -r -p "Pseudo Last.fm : " LASTFM_USER

if [ -z "$LASTFM_KEY" ] || [ -z "$LASTFM_USER" ]; then
  echo "Spotify restera désactivé : la clé ou le pseudo est vide."
fi

if ! command -v python3 >/dev/null 2>&1; then
  echo "Python 3 est requis pour écrire la configuration." >&2
  exit 1
fi

python3 - "$LASTFM_KEY" "$LASTFM_USER" <<'PY'
import re, sys
key, user = sys.argv[1], sys.argv[2]
path = 'script.js'
s = open(path, encoding='utf-8').read()
s, a = re.subn(r"lastfmApiKey: '[^']*'", "lastfmApiKey: '%s'" % key, s)
s, b = re.subn(r"lastfmUser: '[^']*'", "lastfmUser: '%s'" % user, s)
if a != 1 or b != 1:
    sys.exit('Configuration introuvable dans script.js')
open(path, 'w', encoding='utf-8').write(s)
print('Configuration enregistrée dans script.js')
PY

echo
echo "Pour tester : python3 -m http.server 8000, puis ouvre http://localhost:8000"
