#!/bin/bash
# アーカイブから指定期間のダイジェストを組み立てる。
# 直近に注意が偏らないよう、数値は月次・週次の推移として、引用は月ごとの均等サンプリングとして並べる。
# usage: render.sh <since-iso> <until-iso> <outdir> [archive-dir]
set -euo pipefail
trap 'echo "render.sh: failed at line $LINENO" >&2' ERR

since=$1
until=$2
out=$3
arch=${4:-${WEEKLY_REVIEW_ROOT:-$HOME/.claude/weekly-review}/archive}
claude_dir=${CLAUDE_DIR:-$HOME/.claude}
per_month=${DIGEST_PROMPTS_PER_MONTH:-90}
mkdir -p "$out"

digest=$out/digest.md
ev=$out/events.jsonl

# トランスクリプト由来のイベントと、トランスクリプトが消えた期間の history 由来プロンプトを一本化する。
# 質的な傾向は期間全体で地続きに読めるようにし、数値だけを出典で切り分ける
tp_first=$(cat "$arch"/events-*.jsonl 2>/dev/null | jq -r -s 'map(select(.kind=="prompt")|.ts)|min // "9999"')
{
  cat "$arch"/events-*.jsonl 2>/dev/null | jq -c --arg s "$since" --arg u "$until" 'select(.ts >= $s and .ts < $u)'
  if [ -f "$arch/history-prompts.jsonl" ]; then
    jq -c --arg s "$since" --arg u "$until" --arg f "$tp_first" \
      'select(.ts >= $s and .ts < $u and .ts < $f)' "$arch/history-prompts.jsonl"
  fi
} | sort -u > "$ev"

jq -c --arg s "${since:0:10}" --arg u "${until:0:10}" 'select(.date >= $s and .date <= $u)' \
  "$arch/daily.jsonl" > "$out/daily.jsonl"

{
cat <<HEAD
# Claude Code 利用ダイジェスト

期間: $since 〜 $until (UTC)

このダイジェストは推移を読むために作られている。合計値より、月次・週次の推移と、
同じ傾向が複数の月・複数のプロジェクトで観測されるかどうかを重視すること。
引用候補のプロンプトは月ごとに均等サンプリングされているので、
直近の月に証拠が多く見えても、それは実際の偏りではなく単なる活動量の差である。

HEAD

echo "## 月次推移"
echo
jq -r -s '
  def sum(f): map(f) | add // 0;
  group_by(.date[0:7])
  | map({m:.[0].date[0:7], src:(if (map(select(.src=="history"))|length) == length then "history" else "transcript" end),
         d:(map(.date)|unique|length), s:sum(.sessions), p:sum(.prompts),
         c:sum(.prompt_chars), sh:sum(.short), lo:sum(.long), t:sum(.tools), b:sum(.bash),
         i:sum(.interrupts), r:sum(.rejects), e:sum(.errors), a:sum(.asks),
         proj:(map(.project)|unique|length), o:sum(.out_tokens)})
  | "| 月 | 出典 | 稼働日 | セッション | プロンプト | 平均字数 | 短文 | 長文 | ツール | Bash率 | 中断 | 拒否 | エラー | Ask | プロジェクト |\n|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|\n"
    + (map("| \(.m) | \(.src) | \(.d) | \(.s) | \(.p) | \(if .p>0 then (.c/.p|round) else 0 end) | \(.sh) | \(.lo) | "
           + (if .src=="history" then "- | - | - | - | - | - " else "\(.t) | \(if .t>0 then ((.b*100/.t)|round) else 0 end)% | \(.i) | \(.r) | \(.e) | \(.a) " end)
           + "| \(.proj) |") | join("\n"))
' "$out/daily.jsonl"
echo
echo "出典が history の月はトランスクリプトが削除済みで、プロンプト数しか残っていない。"
echo "ツール・中断・エラーの列は空欄であり、0 ではない。この境界をまたいで数値を比較しないこと。"
echo

echo "## 週次推移 (ISO週)"
echo
jq -r -s '
  def sum(f): map(f) | add // 0;
  def week: (.date + "T00:00:00Z" | fromdateiso8601 | strftime("%G-W%V"));
  group_by(week)
  | map({w:(.[0]|week), src:(if (map(select(.src=="history"))|length) == length then "history" else "transcript" end),
         s:sum(.sessions), p:sum(.prompts), t:sum(.tools),
         i:sum(.interrupts), r:sum(.rejects), e:sum(.errors), a:sum(.asks)})
  | "| 週 | 出典 | セッション | プロンプト | ツール | 中断 | 拒否 | エラー | Ask |\n|---|---|---|---|---|---|---|---|---|\n"
    + (map("| \(.w) | \(.src) | \(.s) | \(.p) | "
           + (if .src=="history" then "- | - | - | - | - " else "\(.t) | \(.i) | \(.r) | \(.e) | \(.a) " end) + "|") | join("\n"))
' "$out/daily.jsonl"
echo

echo "## 月 × プロジェクト (プロンプト数、上位12プロジェクト)"
echo
jq -r -s '
  (group_by(.project) | map({p:.[0].project, n:(map(.prompts)|add // 0)}) | sort_by(-.n) | .[0:12]) as $top
  | (map(.date[0:7]) | unique | sort) as $months
  | . as $all
  | "| プロジェクト | " + ($months | join(" | ")) + " | 計 |\n|" + (["---"] + ($months|map("---")) + ["---"] | join("|")) + "|\n"
    + ($top | map(
        .p as $p | .n as $tot
        | "| " + ($p | sub("^" + $ENV.HOME + "/"; "~/")) + " | "
        + ($months | map(. as $m | ($all | map(select(.project==$p and .date[0:7]==$m) | .prompts) | add // 0) | tostring) | join(" | "))
        + " | \($tot) |") | join("\n"))
' "$out/daily.jsonl"
echo

echo "## 時間帯の月別分布 (プロンプト数、ローカル時刻)"
echo
jq -r -s '
  map(select(.kind=="prompt"))
  | group_by(.ts[0:7])
  | map(.[0].ts[0:7] as $m
        | (group_by(.ts[0:19]+"Z" | fromdateiso8601 | strflocaltime("%H"))
           | map({h:(.[0].ts[0:19]+"Z" | fromdateiso8601 | strflocaltime("%H")), n:length})
           | sort_by(.h)) as $h
        | "- **\($m)** " + ($h | map("\(.h)時:\(.n)") | join("  ")))
  | join("\n")
' "$ev"
echo
echo "## 曜日の月別分布 (プロンプト数)"
echo
jq -r -s '
  map(select(.kind=="prompt"))
  | group_by(.ts[0:7])
  | map(.[0].ts[0:7] as $m
        | (group_by(.ts[0:19]+"Z" | fromdateiso8601 | strflocaltime("%u %a"))
           | map({d:(.[0].ts[0:19]+"Z" | fromdateiso8601 | strflocaltime("%u %a")), n:length})
           | sort_by(.d)) as $d
        | "- **\($m)** " + ($d | map("\(.d[2:5]):\(.n)") | join("  ")))
  | join("\n")
' "$ev"
echo

echo "## ツール別呼び出し数の月別推移"
echo
jq -r -s '
  map(select(.kind=="tool_use"))
  | (map(.name) | group_by(.) | map({n:.[0], c:length}) | sort_by(-.c) | .[0:12] | map(.n)) as $tools
  | (map(.ts[0:7]) | unique | sort) as $months
  | . as $all
  | "| tool | " + ($months | join(" | ")) + " |\n|" + (["---"] + ($months|map("---")) | join("|")) + "|\n"
    + ($tools | map(. as $t
        | "| \($t) | " + ($months | map(. as $m | ($all | map(select(.name==$t and .ts[0:7]==$m)) | length) | tostring) | join(" | ")) + " |")
       | join("\n"))
' "$ev"
echo

echo "## Bash 先頭コマンドの月別推移 (上位15)"
echo
jq -r -s '
  map(select(.kind=="tool_use" and .name=="Bash" and .cmd != null)
      | .head = (.cmd | split(" ")[0] | sub("^.*/";"")))
  | (map(.head) | group_by(.) | map({n:.[0], c:length}) | sort_by(-.c) | .[0:15] | map(.n)) as $cmds
  | (map(.ts[0:7]) | unique | sort) as $months
  | . as $all
  | "| command | " + ($months | join(" | ")) + " | 計 |\n|" + (["---"] + ($months|map("---")) + ["---"] | join("|")) + "|\n"
    + ($cmds | map(. as $c
        | "| \($c) | " + ($months | map(. as $m | ($all | map(select(.head==$c and .ts[0:7]==$m)) | length) | tostring) | join(" | "))
          + " | \(($all | map(select(.head==$c)) | length)) |")
       | join("\n"))
' "$ev"
echo

echo "## 訂正・削減・方針表明のシグナル"
echo
echo "プロンプト本文を4種のパターンで分類したもの。好み・価値観の主な証拠源。月別件数のあと全文を引用する。"
echo
jq -r -s '
  def cls:
    if test("ではなく|じゃなく|ではない|違います|違う|やり直|戻して|元に戻|やめて|ではだめ|でいい|で良い") then "訂正"
    elif test("不要|いらない|いりません|要らない|冗長|最小限|削って|削除して|消して|過剰|やりすぎ") then "削減"
    elif test("今後|方針|基本的に|原則|統一|ルール|毎回|常に|以後") then "方針"
    elif test("そもそも|なぜ|なんで|意味あ|必要ですか|必要かな|必要ない|検討して|どう思") then "前提確認"
    else empty end;
  map(select(.kind=="prompt") | . + {c:(.text|cls)})
  | map(select(.c != null))
  | (group_by(.ts[0:7]) | map({m:.[0].ts[0:7],
      t:(map(select(.c=="訂正"))|length), s:(map(select(.c=="削減"))|length),
      p:(map(select(.c=="方針"))|length), q:(map(select(.c=="前提確認"))|length)})) as $bym
  | "| 月 | 訂正 | 削減 | 方針 | 前提確認 |\n|---|---|---|---|---|\n"
    + ($bym | map("| \(.m) | \(.t) | \(.s) | \(.p) | \(.q) |") | join("\n"))
    + "\n\n"
    + (group_by(.c) | map(
        "### \(.[0].c)\n\n" + (sort_by(.ts) | map(
          "- [\(.cwd // "?" | sub("^" + $ENV.HOME + "/"; "~/")) \(.ts[0:19]+"Z" | fromdateiso8601 | strflocaltime("%Y-%m-%d %H:%M"))] \(.text | .[0:400] | gsub("\n"; " "))"
        ) | join("\n"))) | join("\n\n"))
' "$ev"
echo

echo "## AskUserQuestion への回答 (全件)"
echo
jq -r -s '
  map(select(.kind=="ask_answer")) | sort_by(.ts)
  | map("- [\(.cwd // "?" | sub("^" + $ENV.HOME + "/"; "~/")) \(.ts[0:19]+"Z" | fromdateiso8601 | strflocaltime("%Y-%m-%d %H:%M"))]\n"
        + (.answers | to_entries | map("  - Q: \(.key)\n    A: \(.value)") | join("\n")))
  | join("\n")
' "$ev"
echo

echo "## 中断・ツール拒否の全件 (直前の文脈つき)"
echo
jq -r -s '
  sort_by(.ts) as $all
  | ($all | to_entries | map(select(.value.kind=="interrupt" or .value.kind=="tool_reject"))) as $marks
  | $marks | map(
      .key as $i | .value as $v
      | "- [\($v.cwd // "?" | sub("^" + $ENV.HOME + "/"; "~/")) \($v.ts[0:19]+"Z" | fromdateiso8601 | strflocaltime("%Y-%m-%d %H:%M"))] **\($v.kind)**\n"
      + "  - 直前のツール: " + (($all[($i-6):$i] | map(select(.kind=="tool_use") | .name + (if .cmd then "(" + (.cmd|.[0:60]) + ")" else "" end)) | join(" → ")) // "-")
      + "\n  - 直後の発言: " + (($all[($i+1):($i+6)] | map(select(.kind=="prompt") | .text | .[0:200] | gsub("\n";" ")) | .[0]) // "-"))
  | join("\n")
' "$ev"
echo

echo "## ツールエラー上位 (先頭160字)"
echo
jq -r -s '
  map(select(.kind=="tool_error") | .text | gsub("\n";" ") | gsub("\\|";"/") | .[0:120])
  | group_by(.) | map({t:.[0], n:length}) | sort_by(-.n) | .[0:20]
  | "| error | count |\n|---|---|\n" + (map("| \(.t) | \(.n) |") | join("\n"))
' "$ev"
echo

echo "## 月別プロンプト (各月 最大 ${per_month} 件を均等サンプリング)"
echo
echo "出典が history の月はプロンプト文だけが残っている期間で、ツール操作の記録がない。"
echo
jq -r -s --argjson cap "$per_month" '
  map(select(.kind=="prompt" or .kind=="interrupt")) | sort_by(.ts)
  | group_by(.ts[0:7])
  | map(
      .[0].ts[0:7] as $m | length as $n
      | (if $n > $cap then (($n / $cap) | ceil) else 1 end) as $step
      | "### \($m)  (全 \($n) 件中 " + ((to_entries | map(select(.key % $step == 0)) | length) | tostring) + " 件を表示)\n\n"
        + (to_entries | map(select(.key % $step == 0)) | map(.value)
           | map("- [\(.cwd // "?" | sub("^" + $ENV.HOME + "/"; "~/")) \(.ts[0:19]+"Z" | fromdateiso8601 | strflocaltime("%m-%d %H:%M"))] \(.text | .[0:700] | gsub("\n"; "\n  "))")
           | join("\n")))
  | join("\n\n")
' "$ev"
echo

echo "## 期間内に更新された auto memory"
echo
find "$claude_dir/projects" -path '*/memory/*' -name '*.md' -not -name MEMORY.md -newermt "$since" -print0 2>/dev/null \
  | xargs -0 -r -I{} sh -c 'printf -- "- %s\n  - %s\n" "$(echo {} | sed "s|^'"$claude_dir"'/projects/||")" "$(grep -m1 "^description:" {} | cut -c14-)"'
echo
echo "## style ledger の全エントリ (count と最終更新)"
echo
if [ -f "$claude_dir/style/ledger.md" ]; then
  awk '/^### /{name=substr($0,5)} /^- count: /{c=substr($0,10)} /^- first: .* \/ last: /{sub(/.* \/ last: /, ""); print "- " name " (count " c ", last " $0 ")"}' "$claude_dir/style/ledger.md"
fi
echo
echo "## 期間内に作られた plans"
echo
find "$claude_dir/plans" -name '*.md' -newermt "$since" -printf '- %f\n' 2>/dev/null || true

} > "$digest"

echo "render: events $(wc -l < "$ev"), digest $(wc -c < "$digest") bytes"
