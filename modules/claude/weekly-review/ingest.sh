#!/bin/bash
# トランスクリプトから正規化イベントを抽出し、永続アーカイブへ取り込む。
# トランスクリプトは cleanupPeriodDays で消えるが、アーカイブは消えないので長期分析の土台になる。
# 同じトランスクリプトを何度取り込んでも結果は変わらない（冪等）。
# usage: ingest.sh [archive-dir]
set -euo pipefail
trap 'echo "ingest.sh: failed at line $LINENO" >&2' ERR

arch=${1:-${WEEKLY_REVIEW_ROOT:-$HOME/.claude/weekly-review}/archive}
claude_dir=${CLAUDE_DIR:-$HOME/.claude}
mkdir -p "$arch"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

find "$claude_dir/projects" -maxdepth 2 -name '*.jsonl' -print0 \
  | xargs -0 cat \
  | jq -c '
    def txt: if type=="string" then . else ([.[]?|select(.type=="text")|.text]|join("\n")) end;
    def norm_prompt:
      if test("<command-name>") then "/" + (capture("<command-name>/?(?<n>[^<]+)</command-name>").n) + " " + ((capture("<command-args>(?<a>[^<]*)</command-args>")?.a) // "")
      elif startswith("<local-command") or startswith("<system-reminder>") or startswith("<task-notification") then empty
      else . end;
    select(.timestamp != null and (.isSidechain|not))
    | . as $r
    | {ts:$r.timestamp, session:$r.sessionId, cwd:$r.cwd, branch:$r.gitBranch} as $base
    | if .type=="user" then
        (.message.content | if type=="string" then [{type:"text",text:.}] else . end) as $c
        | ([$c[]|select(.type=="text")|.text]|join("\n")) as $t
        | (if ($t|length)>0 then
             ($t|norm_prompt) as $p
             | $base + {kind:(if ($p|startswith("[Request interrupted")) then "interrupt" else "prompt" end),
                        text:($p|.[0:2000]), len:($p|length)}
           else empty end),
          ($c[]|select(.type=="tool_result")
             | (.content|txt) as $m
             | $base + {kind:(if ($m|startswith("The user doesnt want to proceed") or ($m|startswith("The user doesn"))) then "tool_reject"
                              elif .is_error==true then "tool_error" else "tool_ok" end),
                        text:($m|.[0:160])}),
          (if ($r.toolUseResult|type)=="object" and $r.toolUseResult.answers? then $base + {kind:"ask_answer", answers:$r.toolUseResult.answers} else empty end)
      elif .type=="assistant" then
        ($r.message.content[]?|select(.type=="tool_use")
           | $base + {kind:"tool_use", name:.name,
                      cmd:(if .name=="Bash" then (.input.command|tostring|split("\n")[0]|.[0:100]) else null end)}),
        (if $r.requestId then $base + {kind:"usage", req:$r.requestId, model:$r.message.model,
            out:($r.message.usage.output_tokens//0), cr:($r.message.usage.cache_read_input_tokens//0)} else empty end)
      else empty end
  ' > "$tmp/all.jsonl"

# 質的イベントは月別ファイルへ追記し、行単位で重複排除する
jq -r 'select(.kind!="tool_ok" and .kind!="usage") | .ts[0:7] + "|" + tojson' "$tmp/all.jsonl" \
  | awk -F'|' -v d="$tmp" '{m=$1; sub(/^[^|]*\|/,""); print >> (d "/m-" m)}'
touched=0
for f in "$tmp"/m-*; do
  [ -e "$f" ] || continue
  target=$arch/events-${f##*/m-}.jsonl
  { cat "$f"; if [ -f "$target" ]; then cat "$target"; fi; } | sort -u > "$target.new"
  mv "$target.new" "$target"
  touched=$((touched + 1))
done

# 数値は日次・プロジェクト別の集計として保存する
jq -c -s '
  def proj: (.cwd // "?");
  map(select(.ts != null))
  | group_by(.ts[0:10] + " " + proj)
  | map({
      date: .[0].ts[0:10],
      project: (.[0]|proj),
      sessions: (map(.session)|unique|length),
      prompts: (map(select(.kind=="prompt"))|length),
      prompt_chars: (map(select(.kind=="prompt")|.len)|add // 0),
      short: (map(select(.kind=="prompt" and .len<30))|length),
      long: (map(select(.kind=="prompt" and .len>200))|length),
      tools: (map(select(.kind=="tool_use"))|length),
      bash: (map(select(.kind=="tool_use" and .name=="Bash"))|length),
      interrupts: (map(select(.kind=="interrupt"))|length),
      rejects: (map(select(.kind=="tool_reject"))|length),
      errors: (map(select(.kind=="tool_error"))|length),
      asks: (map(select(.kind=="ask_answer"))|length),
      requests: (map(select(.kind=="usage"))|unique_by(.req)|length),
      out_tokens: (map(select(.kind=="usage"))|unique_by(.req)|map(.out)|add // 0)
    })
  | .[]
' "$tmp/all.jsonl" > "$tmp/daily.jsonl"

# トランスクリプトが残っている日は作り直し、消えた日の行はそのまま残す
if [ -s "$arch/daily.jsonl" ]; then
  FRESH_DATES=$(jq -r '.date' "$tmp/daily.jsonl" | sort -u) \
    jq -c '($ENV.FRESH_DATES | split("\n")) as $fresh | . as $row | select($fresh | index($row.date) | not)' \
    "$arch/daily.jsonl" > "$tmp/kept.jsonl"
  cat "$tmp/kept.jsonl" "$tmp/daily.jsonl" | jq -c -s 'sort_by(.date, .project) | .[]' > "$arch/daily.jsonl.new"
  mv "$arch/daily.jsonl.new" "$arch/daily.jsonl"
else
  jq -c -s 'sort_by(.date, .project) | .[]' "$tmp/daily.jsonl" > "$arch/daily.jsonl"
fi

# トランスクリプトが消えた期間は history.jsonl のプロンプトだけが残る。
# これも同じ形に正規化して、長期の傾向分析でトランスクリプト期間と地続きに扱えるようにする
if [ -f "$claude_dir/history.jsonl" ]; then
  jq -c '{ts:(.timestamp/1000|todate), session:.sessionId, cwd:.project, kind:"prompt", src:"history",
          text:(.display|.[0:2000]), len:(.display|length)}' "$claude_dir/history.jsonl" \
    | sort -u > "$arch/history-prompts.jsonl"

  # トランスクリプトが残っていない日だけ、プロンプト数の日次行を history から補う。
  # 前回の補完行は毎回捨てて作り直す（トランスクリプトが後から消えても追随できる）
  jq -c 'select(.src != "history")' "$arch/daily.jsonl" > "$arch/daily.jsonl.new"
  mv "$arch/daily.jsonl.new" "$arch/daily.jsonl"
  jq -r '.date' "$arch/daily.jsonl" | sort -u > "$tmp/have-dates"
  jq -c -s --rawfile have "$tmp/have-dates" '
    ($have | split("\n")) as $have
    | map(select(.ts[0:10] as $d | ($have | index($d)) | not))
    | group_by(.ts[0:10] + " " + (.cwd // "?"))
    | map({date: .[0].ts[0:10], project: (.[0].cwd // "?"), src: "history",
           sessions: (map(.session)|unique|length),
           prompts: length,
           prompt_chars: (map(.len)|add // 0),
           short: (map(select(.len<30))|length),
           long: (map(select(.len>200))|length),
           tools: null, bash: null, interrupts: null, rejects: null,
           errors: null, asks: null, requests: null, out_tokens: null})
    | .[]
  ' "$arch/history-prompts.jsonl" > "$tmp/daily-history.jsonl"

  cat "$arch/daily.jsonl" "$tmp/daily-history.jsonl" \
    | jq -c -s 'sort_by(.date, .project) | .[]' > "$arch/daily.jsonl.new"
  mv "$arch/daily.jsonl.new" "$arch/daily.jsonl"
fi

echo "ingest: $(wc -l < "$tmp/all.jsonl") events, $touched month files, daily rows $(wc -l < "$arch/daily.jsonl")"
