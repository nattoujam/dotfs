#!/bin/bash
# コピー先: $CLAUDE_LOG_BACKUP_DIR（既定: ~/.claude/weekly-review/raw）
set -euo pipefail
trap 'echo "backup.sh: failed at line $LINENO" >&2' ERR

claude_dir=${CLAUDE_DIR:-$HOME/.claude}
dest=${CLAUDE_LOG_BACKUP_DIR:-${WEEKLY_REVIEW_ROOT:-$HOME/.claude/weekly-review}/raw}
mkdir -p "$dest/projects"
touch "$dest/history.jsonl"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

anomalies=0
: > "$tmp/skip"
while IFS= read -r -d '' src; do
  rel=${src#"$claude_dir/projects/"}
  dst=$dest/projects/$rel
  [ -f "$dst" ] || continue
  ssize=$(stat -c %s "$src")
  dsize=$(stat -c %s "$dst")
  if [ "$ssize" -lt "$dsize" ]; then
    echo "shrunk: $rel ($dsize -> $ssize bytes)" >&2
  elif ! cmp -s -n "$dsize" "$src" "$dst"; then
    echo "rewritten: $rel" >&2
  else
    continue
  fi
  printf '/%s\n' "$rel" >> "$tmp/skip"
  anomalies=$((anomalies + 1))
done < <(find "$claude_dir/projects" -name '*.jsonl' -print0)

rsync -a --append --exclude-from="$tmp/skip" \
  --include='*/' --include='*.jsonl' --exclude='*' \
  "$claude_dir/projects/" "$dest/projects/"
rsync -a --exclude='*.jsonl' "$claude_dir/projects/" "$dest/projects/"

if [ -d "$claude_dir/plans" ]; then
  rsync -a "$claude_dir/plans/" "$dest/plans/"
fi

if [ -f "$claude_dir/history.jsonl" ]; then
  awk '!seen[$0]++' "$dest/history.jsonl" "$claude_dir/history.jsonl" > "$tmp/history.jsonl"
  mv "$tmp/history.jsonl" "$dest/history.jsonl"
fi

echo "backup: $(find "$dest/projects" -name '*.jsonl' | wc -l) jsonl, history $(wc -l < "$dest/history.jsonl") lines, $(du -sh "$dest" | cut -f1) -> $dest"

if [ $anomalies -gt 0 ]; then
  echo "backup: $anomalies file(s) skipped because the source is no longer append-only" >&2
  exit 1
fi
