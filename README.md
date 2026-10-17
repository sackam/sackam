# SACKAM WORKS

www.sackam.net 用の静的ポートフォリオ。公開ディレクトリは `dist/`。

## 公開

Webサーバーのドキュメントルートをこのプロジェクトの `dist/` に指定します。ビルドやパッケージのインストールは不要です。

## ローカル確認

```sh
python3 -m http.server 8080 --directory dist
```

http://localhost:8080/ を開きます。

## 編集

- `dist/index.html`: 英語版の紹介文・リンク・メタデータ
- `dist/ja/index.html`: 日本語版（`/ja/`）
- `dist/sitemap.xml`: 英語版・日本語版のサイトマップ
- `dist/robots.txt`: クローラー向け設定・サイトマップの場所
- `dist/404.html`: 英語の404ページ
- `dist/ja/404.html`: `/ja/` 配下用の日本語404ページ（`dist/ja/.htaccess` で設定）
- `dist/language.js`: 日本語ブラウザ向けの言語選択通知（英語の選択はブラウザに保存）
- `dist/style.css`: レイアウト・レスポンシブ対応・作品別配色
- `dist/assets/`: 作品の世界観を表すSVGイラスト、OGP画像とfavicon

SCIENCE ROOMのリンクは提供画像に合わせてHTTPです。HTTPS対応後はindex.htmlの2箇所を変更してください。


## Apacheでのキャッシュ

`dist/.htaccess` をドットファイルごと配置してください。`mod_headers` と、対象ディレクトリでの `AllowOverride FileInfo`（または適切な `AllowOverrideList`）が必要です。

- HTML: `no-cache`。保存を許可し、再利用時はサーバーに更新確認します。
- CSS・JavaScript・画像・フォント: 1日キャッシュ。
- OGP画像（`ogp.jpg`）: 1時間キャッシュ。
- `sitemap.xml`・`robots.txt`: 1時間キャッシュ。

キャッシュ期限後は `ETag`（更新時刻・ファイルサイズ）や `Last-Modified` による条件付きリクエストで、変更がなければ本文を送らず `304 Not Modified` を返せます。日本語版にも親ディレクトリのキャッシュ設定が適用されます。

ファイル名が固定のため `immutable` は付けていません。CSSや画像をすぐに反映したい更新では、参照URLにバージョン（例: `style.css?v=2`）を付けるか、ファイル名を変更してください。SNS事業者側の独自キャッシュはこの設定だけでは削除できません。

Pythonのローカル確認サーバーは `.htaccess` を処理しません。公開後は `curl -I https://www.sackam.net/`、`curl -I https://www.sackam.net/style.css` などで `Cache-Control` を確認できます。
