# ProtoSpace（protospace-48063）

アプリの試作品（プロトタイプ）を画像つきで投稿し、ほかのユーザーからコメントで感想をもらえるサービスです。
テックキャンプ「Webアプリ開発［発展］」の実装課題（9406〜9411）。

- Ruby 3.2.11 / Rails 7.1
- 開発・テスト：SQLite　本番（Render）：PostgreSQL
- 画像：ActiveStorage

# テーブル設計

## users テーブル

| Column             | Type   | Options                   |
| ------------------ | ------ | ------------------------- |
| email              | string | null: false, unique: true |
| encrypted_password | string | null: false               |
| name               | string | null: false               |
| profile            | text   | null: false               |
| occupation         | text   | null: false               |
| position           | text   | null: false               |

### Association

- has_many :prototypes
- has_many :comments

## prototypes テーブル

| Column     | Type       | Options                        |
| ---------- | ---------- | ------------------------------ |
| title      | string     | null: false                    |
| catch_copy | text       | null: false                    |
| concept    | text       | null: false                    |
| user       | references | null: false, foreign_key: true |

※ image は ActiveStorage で持つので、このテーブルの列にはしない

### Association

- belongs_to :user
- has_many :comments

## comments テーブル

| Column    | Type       | Options                        |
| --------- | ---------- | ------------------------------ |
| content   | text       | null: false                    |
| prototype | references | null: false, foreign_key: true |
| user      | references | null: false, foreign_key: true |

### Association

- belongs_to :user
- belongs_to :prototype

# 手元で動かす（Windows）

```
bundle config set --local without production
bundle install --local
bin/rails db:migrate
bin/rails s -p 3105
```

テスト：`bundle exec rspec`
