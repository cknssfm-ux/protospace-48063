#!/usr/bin/env bash
# Render の Build Command で動かすファイル（教材 9383・9411）
# exit on error
set -o errexit

bundle install
bundle exec rake assets:precompile
bundle exec rake assets:clean
bundle exec rake db:migrate

# 本番のデータを全部消してテーブルを作り直したいときだけ、上の db:migrate を消して下の行を使う（教材 9383・9411 後半）
# DISABLE_DATABASE_ENVIRONMENT_CHECK=1 bundle exec rake db:migrate:reset
