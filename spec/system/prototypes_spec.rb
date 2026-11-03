require 'rails_helper'

RSpec.describe 'プロトタイプ', type: :system do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:image_path) { Rails.root.join('spec/fixtures/files/test_image.png') }
  let(:image_path2) { Rails.root.join('spec/fixtures/files/test_image2.png') }

  describe '投稿機能' do
    it 'ログインすると「New Proto」から投稿ページへ行け、正しく投稿するとトップページに一覧で表示される' do
      sign_in(user)
      click_link 'New Proto'
      expect(page).to have_current_path(new_prototype_path)
      fill_in 'prototype_title', with: 'テストアプリ'
      fill_in 'prototype_catch_copy', with: 'すぐ使える'
      fill_in 'prototype_concept', with: '毎日の作業を楽にする'
      attach_file 'prototype_image', image_path
      expect { click_button '保存する' }.to change { Prototype.count }.by(1)
      expect(page).to have_current_path(root_path)
      # 一覧に画像・名称・キャッチコピー・投稿者名
      expect(page).to have_selector("img[src*='test_image.png']")
      expect(page).to have_link('テストアプリ')
      expect(page).to have_content('すぐ使える')
      expect(page).to have_link("by #{user.name}")
    end

    it '空の項目があると投稿できず、投稿ページに留まり、入力した文字は残る' do
      sign_in(user)
      visit new_prototype_path
      fill_in 'prototype_title', with: 'テストアプリ'
      fill_in 'prototype_catch_copy', with: 'すぐ使える'
      attach_file 'prototype_image', image_path
      expect { click_button '保存する' }.not_to change { Prototype.count }
      expect(page).to have_content('コンセプトを入力してください')
      expect(page).to have_field('prototype_title', with: 'テストアプリ')
      expect(page).to have_field('prototype_catch_copy', with: 'すぐ使える')
      expect(page).to have_button('保存する')
    end

    it '画像がないと投稿できない' do
      sign_in(user)
      visit new_prototype_path
      fill_in 'prototype_title', with: 'テストアプリ'
      fill_in 'prototype_catch_copy', with: 'すぐ使える'
      fill_in 'prototype_concept', with: '毎日の作業を楽にする'
      expect { click_button '保存する' }.not_to change { Prototype.count }
      expect(page).to have_content('プロトタイプの画像を入力してください')
      expect(page).to have_field('prototype_concept', with: '毎日の作業を楽にする')
    end

    it 'ログインしていないと投稿ページへ行けず、ログインページへ移る' do
      visit new_prototype_path
      expect(page).to have_current_path(new_user_session_path)
    end
  end

  describe '詳細ページ' do
    let!(:prototype) { create(:prototype, user: user) }

    it 'トップページの画像から詳細ページへ行ける' do
      visit root_path
      find(:xpath, "//a[@href='#{prototype_path(prototype)}'][.//img]").click
      expect(page).to have_current_path(prototype_path(prototype))
    end

    it 'トップページの名称から詳細ページへ行け、名称・投稿者名・画像・キャッチコピー・コンセプトが表示される' do
      visit root_path
      find('a.card__title', text: prototype.title).click
      expect(page).to have_current_path(prototype_path(prototype))
      expect(page).to have_content(prototype.title)
      expect(page).to have_link("by #{user.name}")
      expect(page).to have_selector("img[src*='test_image.png']")
      expect(page).to have_content(prototype.catch_copy)
      expect(page).to have_content(prototype.concept)
    end

    it '投稿した本人には「編集する」「削除する」が表示される' do
      sign_in(user)
      visit prototype_path(prototype)
      expect(page).to have_link('編集する')
      expect(page).to have_button('削除する')
    end

    it '本人以外には「編集する」「削除する」が表示されない' do
      sign_in(other_user)
      visit prototype_path(prototype)
      expect(page).to have_no_link('編集する')
      expect(page).to have_no_button('削除する')
    end

    it 'ログインしていなくても詳細ページは見られる（編集・削除は出ない）' do
      visit prototype_path(prototype)
      expect(page).to have_content(prototype.title)
      expect(page).to have_no_link('編集する')
      expect(page).to have_no_button('削除する')
    end
  end

  describe '編集機能' do
    let!(:prototype) { create(:prototype, user: user) }

    it '詳細ページから編集ページへ行くと、今の内容が入っている' do
      sign_in(user)
      visit prototype_path(prototype)
      click_link '編集する'
      expect(page).to have_current_path(edit_prototype_path(prototype))
      expect(page).to have_field('prototype_title', with: prototype.title)
      expect(page).to have_field('prototype_catch_copy', with: prototype.catch_copy)
      expect(page).to have_field('prototype_concept', with: prototype.concept)
    end

    it '正しく編集すると詳細ページに戻り、新しい内容が表示される（画像の差し替えもできる）' do
      sign_in(user)
      visit edit_prototype_path(prototype)
      fill_in 'prototype_title', with: '新しい名前'
      fill_in 'prototype_concept', with: '新しいコンセプト'
      attach_file 'prototype_image', image_path2
      click_button '保存する'
      expect(page).to have_current_path(prototype_path(prototype))
      expect(page).to have_content('新しい名前')
      expect(page).to have_content('新しいコンセプト')
      expect(page).to have_selector("img[src*='test_image2.png']")
    end

    it '画像を選ばずに保存しても、前の画像が残る' do
      sign_in(user)
      visit edit_prototype_path(prototype)
      fill_in 'prototype_catch_copy', with: '新しいキャッチコピー'
      click_button '保存する'
      expect(page).to have_current_path(prototype_path(prototype))
      expect(page).to have_content('新しいキャッチコピー')
      expect(page).to have_selector("img[src*='test_image.png']")
    end

    it '空の項目があると更新できず、編集ページに留まり、入力した文字は残る' do
      sign_in(user)
      visit edit_prototype_path(prototype)
      fill_in 'prototype_title', with: ''
      fill_in 'prototype_concept', with: '書きかけのコンセプト'
      click_button '保存する'
      expect(page).to have_content('プロトタイプの名称を入力してください')
      expect(page).to have_field('prototype_concept', with: '書きかけのコンセプト')
      expect(prototype.reload.title).not_to eq('')
    end

    it '本人以外が編集ページのURLを開くとトップページへ戻される' do
      sign_in(other_user)
      visit edit_prototype_path(prototype)
      expect(page).to have_current_path(root_path)
    end

    it 'ログインしていないと編集ページのURLを開いてもログインページへ移る' do
      visit edit_prototype_path(prototype)
      expect(page).to have_current_path(new_user_session_path)
    end
  end

  describe '削除機能' do
    let!(:prototype) { create(:prototype, user: user) }

    it '詳細ページの「削除する」で消え、トップページに戻る' do
      create(:comment, prototype: prototype)
      sign_in(user)
      visit prototype_path(prototype)
      expect { click_button '削除する' }.to change { Prototype.count }.by(-1).and change { Comment.count }.by(-1)
      expect(page).to have_current_path(root_path)
      expect(page).to have_no_link(prototype.title)
    end
  end
end
