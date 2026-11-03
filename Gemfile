source "https://rubygems.org"

# 教材は ruby "3.2.0" と MySQL。このPCは Ruby 3.2.11 と SQLite に置き換えている
ruby "3.2.11"

gem "rails", "~> 7.1.0"
gem "sprockets-rails"

# 開発・テストは SQLite（教材の MySQL の代わり）
group :development, :test do
  gem "sqlite3", "~> 1.4"
end

# 本番（Render）は PostgreSQL。手元の Windows には入れない（bundle config set --local without production）
group :production do
  gem "pg"
end

gem "puma", ">= 5.0"
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "jbuilder"

gem "tzinfo-data", platforms: %i[ windows jruby ]

# ユーザー管理
gem "devise"

group :development, :test do
  gem "debug", platforms: %i[ mri windows ]
  gem "rspec-rails", "~> 7.1"
  gem "factory_bot_rails"
  gem "faker"
end

group :development do
  gem "web-console"
end

group :test do
  gem "capybara"
  gem "rails-controller-testing"
end

gem "pry-rails"
