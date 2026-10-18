#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.."
python3 scripts/build.py --check
for name in SAKURA_HOST SAKURA_USER SAKURA_PUBLIC_DIR SAKURA_KNOWN_HOSTS SAKURA_SSH_KEY; do
  if [[ -z "${!name:-}" ]]; then
    printf 'Required environment variable is missing: %s\n' "$name" >&2
    exit 1
  fi
done
SAKURA_PORT="${SAKURA_PORT:-22}"
# Restrict values interpolated into SSH destinations and remote shell commands.
[[ "$SAKURA_HOST" =~ ^[a-zA-Z0-9][a-zA-Z0-9.-]*$ ]] || { echo 'Invalid SAKURA_HOST' >&2; exit 1; }
[[ "$SAKURA_USER" =~ ^[a-zA-Z0-9_][a-zA-Z0-9_-]*$ ]] || { echo 'Invalid SAKURA_USER' >&2; exit 1; }
[[ "$SAKURA_PORT" =~ ^[0-9]+$ ]] && (( SAKURA_PORT >= 1 && SAKURA_PORT <= 65535 )) || { echo 'Invalid SAKURA_PORT' >&2; exit 1; }
[[ "$SAKURA_PUBLIC_DIR" =~ ^/home/[a-zA-Z0-9_-]+/www/[a-zA-Z0-9/._-]+$ ]] && [[ "/${SAKURA_PUBLIC_DIR}/" != *'/../'* ]] || { echo 'Invalid SAKURA_PUBLIC_DIR' >&2; exit 1; }
[[ -f dist/index.html && ! -L dist/index.html ]] || { echo 'Missing dist/index.html.' >&2; exit 1; }
[[ -d dist/assets && ! -L dist/assets ]] || { echo 'Missing dist/assets/.' >&2; exit 1; }

deploy_tmp=$(mktemp -d)
trap 'rm -rf -- "$deploy_tmp"' EXIT
chmod 700 "$deploy_tmp"
printf '%s\n' "$SAKURA_SSH_KEY" | tr -d '\r' > "$deploy_tmp/key"
printf '%s\n' "$SAKURA_KNOWN_HOSTS" > "$deploy_tmp/known_hosts"
chmod 600 "$deploy_tmp/key" "$deploy_tmp/known_hosts"
ssh_options=(-p "$SAKURA_PORT" -i "$deploy_tmp/key" -o BatchMode=yes -o IdentitiesOnly=yes -o StrictHostKeyChecking=yes -o "UserKnownHostsFile=$deploy_tmp/known_hosts" -o ConnectTimeout=20)

# Upload assets first, then HTML, so new HTML only references uploaded assets.
# Keep existing remote files: cached pages may still reference older assets.
tar -C dist --exclude='*.html' --exclude='.DS_Store' --exclude='._*' -czf "$deploy_tmp/assets.tar.gz" .
(cd dist && find . -type f -name '*.html' -print0) > "$deploy_tmp/html-files"
tar -C dist -czf "$deploy_tmp/html.tar.gz" --null -T "$deploy_tmp/html-files"
for archive in assets html; do
  ssh "${ssh_options[@]}" "$SAKURA_USER@$SAKURA_HOST" \
    "mkdir -p '$SAKURA_PUBLIC_DIR' && tar -xzf - -C '$SAKURA_PUBLIC_DIR'" < "$deploy_tmp/$archive.tar.gz"
done
printf 'Deployment complete.\n'
