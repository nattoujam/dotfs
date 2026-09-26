#!/bin/bash
# Claude Code の利用ログを分析する。
#   claude-weekly-review                     直近7日の運用レビュー
#   claude-weekly-review --trend --days 90   長期トレンドレビュー
#   claude-weekly-review --trend --all       記録が残っている全期間
# 共通オプション: --no-notes（NextCloud へ投稿しない） --dry-run（ダイジェストまでで止める）
set -euo pipefail
trap 'echo "run.sh: failed at line $LINENO" >&2' ERR

here=$(dirname "$(readlink -f "$0")")
root=${WEEKLY_REVIEW_ROOT:-$HOME/.claude/weekly-review}
# 分析モデルは固定する。settings.json を引き継ぐと対話用の /model 切り替えが
# そのまま自動実行に効いてしまい、傾向の変化なのか分析者の変化なのか切り分けられなくなる
model=${WEEKLY_REVIEW_MODEL:-opus}
mode=weekly
days=7
days_given=0
post_notes=1
dry_run=0
while [ $# -gt 0 ]; do
  case $1 in
    --trend) mode=trend; days=90; shift ;;
    --days) days=$2; days_given=1; shift 2 ;;
    --all) days=all; days_given=1; shift ;;
    --no-notes) post_notes=0; shift ;;
    --dry-run) dry_run=1; shift ;;
    *) echo "unknown option: $1" >&2; exit 1 ;;
  esac
done

now=$(date +%s)
until=$(date -u -d "@$now" +%Y-%m-%dT%H:%M:%SZ)

if [ "$mode" = trend ]; then
  slot=trend/$(date +%Y-%m)
  prompt_file=$here/prompt-trend.md
  report_name=trend.md
  note_title="Claude Code トレンドレビュー $(date +%Y-%m)"
else
  slot=$(date -d "@$((now - 86400))" +%G-W%V)
  prompt_file=$here/prompt-weekly.md
  report_name=report.md
  note_title="Claude Code 週次レビュー $slot"
fi
dir=$root/$slot
mkdir -p "$dir"

log() { printf '%s %s\n' "$(date +%H:%M:%S)" "$*" >&2; }
period_of() { sed -n 's/^期間: \([^ ]*\) 〜 \([^ ]*\) (UTC)$/\1 \2/p' "$1" 2>/dev/null; }

prev=$(ls -t "$root"/*/"$report_name" "$root"/*/*/"$report_name" 2>/dev/null | grep -v "^$dir/" | head -1 || true)

since=
if [ "$days" = all ]; then
  since=2020-01-01T00:00:00Z
elif [ "$mode" = weekly ] && [ $days_given -eq 0 ]; then
  if [ -f "$dir/$report_name" ]; then
    since=$(period_of "$dir/digest.md" | cut -d' ' -f1)
  elif [ -n "$prev" ]; then
    since=$(period_of "$(dirname "$prev")/digest.md" | cut -d' ' -f2)
  fi
  if [ -n "$since" ] && [ $((now - $(date -d "$since" +%s))) -gt $((28 * 86400)) ]; then
    since=
  fi
fi
if [ -z "$since" ]; then
  since=$(date -u -d "@$((now - days * 86400))" +%Y-%m-%dT%H:%M:%SZ)
fi
if [ "$days" = all ]; then
  period_desc="記録が残っている全期間"
else
  period_desc="直近 $(( (now - $(date -d "$since" +%s) + 43200) / 86400 )) 日間"
fi

log "ingest: transcripts -> archive"
"$here/ingest.sh" "$root/archive"
log "render: $since .. $until -> $dir"
"$here/render.sh" "$since" "$until" "$dir" "$root/archive"

# 累積プロファイルと前回レポートを作業ディレクトリへ持ち込む
rm -f "$dir/profile.md" "$dir/prev-report.md"
if [ -f "$root/profile.md" ]; then cp "$root/profile.md" "$dir/profile.md"; fi
if [ -n "$prev" ]; then
  cp "$prev" "$dir/prev-report.md"
  log "prev report: $prev"
fi

if [ $dry_run -eq 1 ]; then
  log "dry-run: digest only"
  exit 0
fi

# 分析セッション自身が次回の分析対象に混ざらないよう、セッションも履歴も残さない
export CLAUDE_CODE_SKIP_PROMPT_HISTORY=1

cd "$dir"
attempt=0
while :; do
  attempt=$((attempt + 1))
  log "claude -p (attempt $attempt, mode=$mode)"
  if claude -p "$(printf 'digest.md を起点に、システムプロンプトの指示どおり %s の利用レビューを書いてください。期間: %s 〜 %s (UTC)\n\nこの分析を実行しているモデルは %s です。profile.md の「計測上の注意」に、どの期間をどのモデルが分析したかを 1 行で残してください。\n\n出力はファイルに書かず、標準出力に次の形だけを出すこと。1行目は必ず ===REPORT=== から始める。\n\n===REPORT===\n(レポート本文)\n===PROFILE===\n(profile.md の全文)' "$period_desc" "$since" "$until" "$model")" \
      --model "$model" \
      --settings '{"outputStyle":"default"}' \
      --append-system-prompt-file "$here/prompt-common.md" \
      --append-system-prompt-file "$prompt_file" \
      --output-format json \
      --no-session-persistence \
      --permission-prompts none \
      --permission-mode dontAsk \
      --setting-sources user \
      --add-dir "$HOME/.claude" \
      --max-turns 80 \
      --allowedTools 'Read,Bash(jq *),Bash(rg *),Bash(grep *),Bash(cat *),Bash(head *),Bash(tail *),Bash(wc *),Bash(sort *),Bash(uniq *),Bash(ls *),Bash(find *),Bash(awk *),Bash(sed -n *),Bash(cut *),Bash(tr *),Bash(paste *),Bash(column *),Bash(echo *),Bash(cd *),Bash(printf *),Bash(bc *),Bash(date *)' \
      < /dev/null > run.json 2> run.stderr; then
    break
  fi
  log "claude -p failed"
  if [ $attempt -ge 3 ]; then
    log "giving up; see $dir/run.stderr"
    exit 1
  fi
  sleep 60
done

if [ "$(jq -r '.is_error' run.json)" = "true" ]; then
  log "claude returned is_error: $(jq -r '.result' run.json | head -3)"
  exit 1
fi

jq -r '.result' run.json > raw.md
awk '/^===REPORT===$/{r=1;p=0;next} /^===PROFILE===$/{r=0;p=1;next} r{print > "'"$dir/$report_name"'"} p{print > "'"$dir/profile.new.md"'"}' raw.md

if [ ! -s "$dir/$report_name" ]; then
  log "no ===REPORT=== block in output; keeping raw.md as the report"
  cp raw.md "$dir/$report_name"
fi
if [ -s "$dir/profile.new.md" ] && ! grep -q '^| id |' "$dir/profile.new.md"; then
  log "profile has no '| id |' table header; rejecting it and keeping the previous profile"
  mv "$dir/profile.new.md" "$dir/profile.rejected.md"
fi
if [ -s "$dir/profile.new.md" ]; then
  if [ -f "$root/profile.md" ]; then
    mkdir -p "$root/profile-history"
    cp "$root/profile.md" "$root/profile-history/profile-$(date +%Y%m%d%H%M%S).md"
  fi
  mv "$dir/profile.new.md" "$root/profile.md"
  log "profile updated: $root/profile.md ($(wc -c < "$root/profile.md") bytes)"
else
  log "no ===PROFILE=== block in output; profile left unchanged"
fi

log "report: $dir/$report_name ($(wc -c < "$dir/$report_name") bytes, turns=$(jq -r '.num_turns' run.json), est_cost=\$$(jq -r '.total_cost_usd' run.json))"

if [ $post_notes -eq 1 ] && command -v nc-notes >/dev/null 2>&1; then
  post_note() {
    local title=$1 body=$2 id
    id=$(nc-notes list --category claude-review 2>/dev/null \
      | awk -v t="$title" '{id=$1; sub(/^[0-9]+ +[^ ]+ +/, ""); if ($0==t) {print id; exit}}' || true)
    if [ -n "$id" ]; then
      nc-notes update "$id" < "$body" >/dev/null && log "notes: updated $id ($title)"
    else
      nc-notes create --title "$title" --category claude-review < "$body" >/dev/null && log "notes: created ($title)"
    fi
  }
  post_note "$note_title" "$dir/$report_name"
  if [ -f "$root/profile.md" ]; then post_note "Claude Code 利用プロファイル" "$root/profile.md"; fi
fi
