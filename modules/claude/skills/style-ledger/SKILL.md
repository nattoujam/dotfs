---
name: style-ledger
description: Review, promote, and prune the user's coding-style feedback ledger at ~/.claude/style/ledger.md. Use when the user wants to see what style preferences have been accumulated, asks "何を学習した" / "スタイルの棚卸し" / "昇格候補ある？", wants to promote a recurring preference into ~/.claude/rules/, wants to retire a rule that no longer applies, or asks to manually log a style correction. Not needed for ordinary logging during a task — that is covered by the instruction in ~/.claude/CLAUDE.md.
---

# コーディングスタイル台帳の棚卸し

台帳は `~/.claude/style/ledger.md`。記録・昇格・棚卸しの運用ルールは台帳の冒頭に書いてあるので、**まず台帳を読むこと**。

引数に応じて動作を変える。引数がなければ `list` として扱う。

## `list`

台帳を読み、エントリを一覧する。`status: retired` は既定で畳む。

出力は次の3グループに分ける。

1. **昇格候補** — `count >= 3` または明示指示で、まだ `status: observed` のもの
2. **昇格済み** — `status: promoted`（昇格先も示す）
3. **観察中** — それ以外（count の多い順）

昇格候補があれば、そのまま `promote` の提案まで続ける。

## `promote [<id>]`

`<id>` の指定がなければ昇格候補から選ぶ。

1. 台帳の `scope` から昇格先を決める（`global` → `~/.claude/rules/coding-style.md`、`ruby`/`rails` → `~/.claude/rules/ruby.md`、プロジェクト固有 → そのリポジトリの `CLAUDE.md`）
2. **`rules/` に書く文面を提示して承認を得る。** 承認前にファイルを書かないこと。`rules/` は毎セッション読み込まれるため context コストがかかる
3. `~/.claude/rules/ruby.md` を新規作成する場合は `paths` frontmatter を付け、該当ファイルを触ったときだけ読み込ませる

   ```markdown
   ---
   paths:
     - "**/*.rb"
     - "**/*.erb"
   ---
   ```
4. 書き込んだら台帳側を `status: promoted` にし、昇格先を追記する

## `prune`

1. `status: retired` のエントリを台帳から削除する（`rules/` 側にも残っていれば併せて外す）
2. `count: 1` のまま180日以上 `last` が動いていないエントリを棚卸し候補として提示する。**自動削除はしない** — ユーザーの判断を仰ぐ
3. 同じ根っこの選好が別エントリに分かれていないか点検し、統合を提案する

## `log <指摘内容>`

台帳の記録手順に従って1件記録する。既存エントリと根っこが同じなら `count` を増やす。

## 注意

- 台帳のエントリは**正規化された選好**であって、指摘の逐語コピーではない。`evidence` に原文を残し、`rule` は再利用できる一文に書き直す
- 昇格した文面は具体的に書く。「適切にテストを書く」ではなく「一意性制約のある属性の factory は sequence で一意化する」のように、検証できる粒度にすること
