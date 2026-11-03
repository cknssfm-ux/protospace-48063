# ProtoSpace を Render に公開する手順（オーナーが自分でやる）

アプリの準備は済んでいます（`bin/render-build.sh`・本番の DB 設定・Gemfile の pg・Linux 用の Gemfile.lock）。
残っているのは「アカウントが要る作業」と「ネットに出す作業」だけです。プランはすべて **無料（Free）**。

## 0. 先に知っておくこと
- Render の無料の DB は **1つまで**。AjaxApp の DB はまだ作っていないので、**休止の作業はいりません**（教材 9411 の「AjaxApp のデータベースを休止しよう」は飛ばしてよい）。あとで AjaxApp も公開するときは、どちらかの DB を「Suspend Database」で休ませる
- 無料の DB は作ってから 90 日で使えなくなる
- 投稿した画像は、しばらくすると消える（無料の Render はファイルを残せないため。教材どおりの仕様）

## 1. GitHub に上げる（公開リポジトリ）
1. GitHub で **public** のリポジトリ `protospace-48063` を作る（中身は空のまま）
2. このフォルダはすでに git で「first commit」から機能ごとにコミット済み。PowerShell でこのフォルダに入って：
   ```
   git remote add origin https://github.com/<GitHubのユーザー名>/protospace-48063.git
   git push -u origin main
   ```
   （GitHub Desktop なら「Add Existing Repository」でこのフォルダを選び → Publish。**Keep this code private のチェックは外す**）
3. `config/master.key` が GitHub に上がっていないことを画面で確認（`.gitignore` 済み）

## 2. Render の画面での作業
1. Render に GitHub でサインアップ／ログイン（GitHub との連携の許可はオーナーが押す）
2. 「New +」→「**PostgreSQL**」
   - Name：`protospace_production`、Region：**Oregon** か **Ohio**（あとの Web Service と同じにする）
   - Plan：**Free** → Create Database
   - できたら **Internal Database URL** をコピーして控える
3. 「New +」→「**Web Service**」→ `protospace-48063` のリポジトリを Connect
   - Name：`protospace-48063`
   - Region：2 と同じ
   - Language（Runtime）：Ruby
   - Build Command：`./bin/render-build.sh`
   - Start Command：`bundle exec puma -C config/puma.rb`
   - Instance Type：**Free**
4. 「Environment Variables」で2つ入れる

   | Key | Value |
   |---|---|
   | RAILS_MASTER_KEY | `config/master.key` の中身（1行） |
   | DATABASE_URL | 2 で控えた Internal Database URL |

5. 「Create Web Service」→ ログに `Your service is live` が出たら、上の URL を開く

## 3. 公開したあとの確認（教材のセルフチェック表）
- 新規登録 → ログアウト → ログイン ができる
- New Proto で画像つき投稿 → トップに出る → 詳細 → 編集 → 削除
- 別のユーザーでログインし、コメントできる・人の投稿に編集/削除が出ない
- ユーザー名を押すとユーザー詳細ページ

## うまくいかないとき
- `Permission denied`（render-build.sh）：Build Command を `bash bin/render-build.sh` に変える
- `ActiveSupport::MessageEncryptor::InvalidMessage`：RAILS_MASTER_KEY が違う。`config/master.key` の中身をそのまま入れ直す
- DB につながらない：DATABASE_URL が **Internal** の方か、DB と Web Service の Region が同じかを見る
- 手元（Windows）で gem を入れ直すとき：`bundle config set --local without production` のあと `bundle install`（pg は手元に入れない）
