# テスト構成

## 実行方法

```bash
# 全テスト実行
bash tests/run.sh

# 特定のテストファイルのみ実行
bash tests/run.sh tests/cases/test_cli_typ.sh
bash tests/run.sh tests/cases/test_cli_md.sh
bash tests/run.sh tests/cases/test_compile.sh
```

## ディレクトリ構成

```
tests/
├── README.md
├── run.sh               # テストランナー（全件 or 指定ファイル）
├── helpers.sh           # アサーションヘルパー・run_tests 関数
├── fixtures/
│   ├── sample.md        # CLI テスト用 Markdown
│   └── sample.typ       # CLI テスト用 Typst
└── cases/
    ├── test_cli_typ.sh  # altyp convert .typ 入力テスト
    ├── test_cli_md.sh   # altyp convert .md 入力テスト
    └── test_compile.sh  # テンプレート全パラメータコンパイルテスト
```

## テストカテゴリ

### CLI テスト（test_cli_*.sh）

`altyp convert` コマンドの引数処理と出力を検証する。

| テスト | 内容 |
|---|---|
| `.typ` 入力 → PDF 生成 | ファイルが存在し空でないことを確認 |
| `-o` オプション | 指定パスに出力されること |
| 存在しないファイル | エラー終了すること |
| `.md` 入力 → Typst 生成 | always-typst import が含まれること |
| `.md` 入力 → PDF 生成 | `--to pdf` でPDFが生成されること |
| H1 自動タイトル抽出 | 生成 .typ にタイトルが含まれること |
| `--title` 明示指定 | 指定タイトルが反映されること |
| `--layout` オプション | 指定レイアウトが反映されること |

### コンパイルテスト（test_compile.sh）

テンプレートの全パラメータ組み合わせでコンパイルエラーがないことを検証する。

- **document**: layout（print / mobile / wide）× tone（casual / business / stylish）× color（blue / green / mono / warm / purple / teal）= **54ケース**
- **slide**: tone × color = **18ケース**

合計 **72ケース**。

## テスト更新が必要なタイミング

| 変更内容 | 更新対象 |
|---|---|
| `altyp convert` のオプション追加・変更 | `test_cli_typ.sh` / `test_cli_md.sh` |
| 新しい layout / tone / color の追加 | `test_compile.sh` の配列に追加 |
| テンプレートの構造変更 | `test_compile.sh`（コンパイルエラーで検出） |
| fixtures の内容変更 | 対応するCLIテストの期待値を確認 |
