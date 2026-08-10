#!/usr/bin/env bash
# NextCloud Notes CLI (Notes REST API v1 wrapper)
set -euo pipefail

CONFIG_FILE="${NC_NOTES_CONFIG:-$HOME/.config/nc-notes/env}"

if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "設定ファイルが見つかりません: $CONFIG_FILE" >&2
  exit 1
fi
# shellcheck disable=SC1090
source "$CONFIG_FILE"

: "${NC_NOTES_URL:?NC_NOTES_URL が設定されていません ($CONFIG_FILE)}"
: "${NC_NOTES_USER:?NC_NOTES_USER が設定されていません ($CONFIG_FILE)}"
: "${NC_NOTES_PASSWORD:?NC_NOTES_PASSWORD が設定されていません ($CONFIG_FILE)}"

API_BASE="${NC_NOTES_URL%/}/index.php/apps/notes/api/v1"

usage() {
  cat <<'EOF'
使い方: nc-notes <command> [options]

Commands:
  list [--category CAT] [--favorite]     ノート一覧 (id, title, category を表示)
  search <keyword> [--category CAT] [-C N] [--regex] [--ids-only]
                                          全文検索。ヒットした前後N行(既定2)のみ表示。
                                          本文全体は表示しないためcontext消費を抑えられる
                                          (--ids-only で id/category/title だけ表示)
  get <id> [--json]                      ノート本文を表示 (--json で全メタデータ)
  create --title TITLE [--category CAT] [--favorite]
                                          新規ノート作成。本文は標準入力から読む
                                          (例: echo "本文" | nc-notes create --title "件名")
  update <id> [--title TITLE] [--category CAT] [--favorite|--no-favorite]
                                          ノート更新。本文をパイプで渡すと content を更新、
                                          渡さなければ content は変更しない
  delete <id>                            ノート削除
  help                                   このヘルプを表示
EOF
}

api() {
  # api <method> <path> [curl-extra-args...]
  local method="$1" path="$2"
  shift 2
  curl -sS -u "${NC_NOTES_USER}:${NC_NOTES_PASSWORD}" \
    -H "Accept: application/json" \
    -X "$method" \
    -w '\n%{http_code}' \
    "${API_BASE}${path}" "$@"
}

check_status() {
  # check_status <http_code> <body>
  local code="$1" body="$2"
  case "$code" in
    2??) return 0 ;;
    401) echo "認証エラー: NC_NOTES_USER / NC_NOTES_PASSWORD を確認してください" >&2 ;;
    403) echo "エラー: 読み取り専用ノートです" >&2 ;;
    404) echo "エラー: ノートが見つかりません" >&2 ;;
    412) echo "エラー: 他の場所での更新と競合しました (412)" >&2 ;;
    *) echo "エラー: HTTP $code" >&2 ;;
  esac
  echo "$body" >&2
  exit 1
}

cmd_list() {
  local category="" favorite_only=0
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --category) category="$2"; shift 2 ;;
      --favorite) favorite_only=1; shift ;;
      *) echo "不明なオプション: $1" >&2; exit 1 ;;
    esac
  done

  local qs="exclude=content"
  [[ -n "$category" ]] && qs="${qs}&category=$(printf '%s' "$category" | jq -sRr @uri)"

  local resp code body
  resp="$(api GET "/notes?${qs}")"
  code="$(tail -n1 <<<"$resp")"
  body="$(sed '$d' <<<"$resp")"
  check_status "$code" "$body"

  if [[ "$favorite_only" -eq 1 ]]; then
    jq -r '.[] | select(.favorite==true) | [.id, .category, .title] | @tsv' <<<"$body"
  else
    jq -r '.[] | [.id, .category, .title] | @tsv' <<<"$body"
  fi | column -t -s $'\t'
}

cmd_search() {
  [[ $# -ge 1 ]] || { echo "検索キーワードを指定してください" >&2; exit 1; }
  local keyword="$1"; shift
  local category="" context=2 grep_mode="-F" ids_only=0
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --category) category="$2"; shift 2 ;;
      -C|--context) context="$2"; shift 2 ;;
      --regex) grep_mode="-E"; shift ;;
      --ids-only) ids_only=1; shift ;;
      *) echo "不明なオプション: $1" >&2; exit 1 ;;
    esac
  done

  local resp code body
  resp="$(api GET "/notes")"
  code="$(tail -n1 <<<"$resp")"
  body="$(sed '$d' <<<"$resp")"
  check_status "$code" "$body"

  local row note id title cat content title_hit matches
  while IFS= read -r row; do
    note="$(base64 -d <<<"$row")"
    id="$(jq -r '.id' <<<"$note")"
    title="$(jq -r '.title' <<<"$note")"
    cat="$(jq -r '.category' <<<"$note")"

    if [[ -n "$category" && "$cat" != "$category" ]]; then
      continue
    fi

    content="$(jq -r '.content' <<<"$note")"

    title_hit=0
    grep -qi "$grep_mode" -- "$keyword" <<<"$title" && title_hit=1

    matches="$(grep -n -i "$grep_mode" -C "$context" -- "$keyword" <<<"$content" || true)"

    if [[ -z "$matches" && "$title_hit" -eq 0 ]]; then
      continue
    fi

    if [[ "$ids_only" -eq 1 ]]; then
      printf '%s\t%s\t%s\n' "$id" "$cat" "$title"
    else
      echo "=== id=${id} [${cat}] ${title} ==="
      [[ -n "$matches" ]] && echo "$matches"
      echo
    fi
  done < <(jq -r '.[] | @base64' <<<"$body")
}

cmd_get() {
  [[ $# -ge 1 ]] || { echo "id を指定してください" >&2; exit 1; }
  local id="$1"; shift
  local as_json=0
  [[ "${1:-}" == "--json" ]] && as_json=1

  local resp code body
  resp="$(api GET "/notes/${id}")"
  code="$(tail -n1 <<<"$resp")"
  body="$(sed '$d' <<<"$resp")"
  check_status "$code" "$body"

  if [[ "$as_json" -eq 1 ]]; then
    jq '.' <<<"$body"
  else
    jq -r '.content' <<<"$body"
  fi
}

cmd_create() {
  local title="" category="" favorite=false
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --title) title="$2"; shift 2 ;;
      --category) category="$2"; shift 2 ;;
      --favorite) favorite=true; shift ;;
      *) echo "不明なオプション: $1" >&2; exit 1 ;;
    esac
  done
  [[ -n "$title" ]] || { echo "--title は必須です" >&2; exit 1; }

  local content=""
  if [[ ! -t 0 ]]; then
    content="$(cat)"
  fi

  local payload
  payload="$(jq -n --arg title "$title" --arg content "$content" \
    --arg category "$category" --argjson favorite "$favorite" \
    '{title: $title, content: $content, category: $category, favorite: $favorite}')"

  local resp code body
  resp="$(api POST "/notes" -H "Content-Type: application/json" -d "$payload")"
  code="$(tail -n1 <<<"$resp")"
  body="$(sed '$d' <<<"$resp")"
  check_status "$code" "$body"

  jq -r '"作成しました: id=\(.id) title=\(.title)"' <<<"$body"
}

cmd_update() {
  [[ $# -ge 1 ]] || { echo "id を指定してください" >&2; exit 1; }
  local id="$1"; shift
  local title="" category="" favorite=""
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --title) title="$2"; shift 2 ;;
      --category) category="$2"; shift 2 ;;
      --favorite) favorite=true; shift ;;
      --no-favorite) favorite=false; shift ;;
      *) echo "不明なオプション: $1" >&2; exit 1 ;;
    esac
  done

  local content=""
  local has_content=false
  if [[ ! -t 0 ]]; then
    content="$(cat)"
    has_content=true
  fi

  local payload="{}"
  [[ -n "$title" ]] && payload="$(jq --arg v "$title" '. + {title:$v}' <<<"$payload")"
  [[ -n "$category" ]] && payload="$(jq --arg v "$category" '. + {category:$v}' <<<"$payload")"
  [[ -n "$favorite" ]] && payload="$(jq --argjson v "$favorite" '. + {favorite:$v}' <<<"$payload")"
  [[ "$has_content" == true ]] && payload="$(jq --arg v "$content" '. + {content:$v}' <<<"$payload")"

  local resp code body
  resp="$(api PUT "/notes/${id}" -H "Content-Type: application/json" -d "$payload")"
  code="$(tail -n1 <<<"$resp")"
  body="$(sed '$d' <<<"$resp")"
  check_status "$code" "$body"

  jq -r '"更新しました: id=\(.id) title=\(.title)"' <<<"$body"
}

cmd_delete() {
  [[ $# -ge 1 ]] || { echo "id を指定してください" >&2; exit 1; }
  local id="$1"

  local resp code body
  resp="$(api DELETE "/notes/${id}")"
  code="$(tail -n1 <<<"$resp")"
  body="$(sed '$d' <<<"$resp")"
  check_status "$code" "$body"

  echo "削除しました: id=${id}"
}

main() {
  local cmd="${1:-help}"
  [[ $# -gt 0 ]] && shift || true

  case "$cmd" in
    list) cmd_list "$@" ;;
    search) cmd_search "$@" ;;
    get) cmd_get "$@" ;;
    create) cmd_create "$@" ;;
    update) cmd_update "$@" ;;
    delete) cmd_delete "$@" ;;
    help|-h|--help) usage ;;
    *) echo "不明なコマンド: $cmd" >&2; usage; exit 1 ;;
  esac
}

main "$@"
