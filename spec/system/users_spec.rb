require 'rails_helper'

RSpec.describe 'ユーザー管理機能', type: :system do
  let(:user) { build(:user) }

  def fill_in_sign_up(user)
    fill_in 'user_email', with: user.email
    fill_in 'user_password', with: user.password
    fill_in 'user_password_confirmation', with: user.password_confirmation
    fill_in 'user_name', with: user.name
    fill_in 'user_profile', with: user.profile
    fill_in 'user_occupation', with: user.occupation
    fill_in 'user_position', with: user.position
  end

  describe '新規登録' do
    it 'トップページから新規登録ページへ行き、正しく登録するとトップページに戻る' do
      visit root_path
      click_link '新規登録'
      expect(page).to have_current_path(new_user_registration_path)
      fill_in_sign_up(user)
      expect { click_button '新規登録' }.to change { User.count }.by(1)
      expect(page).to have_current_path(root_path)
      # ログイン中のヘッダーと「こんにちは」
      expect(page).to have_button('ログアウト')
      expect(page).to have_link('New Proto')
      expect(page).to have_no_link('ログイン')
      expect(page).to have_no_link('新規登録')
      expect(page).to have_content("こんにちは、#{user.name}さん")
    end

    it '必須項目が空だと登録できず、新規登録ページに留まる（入力した文字は残る）' do
      visit new_user_registration_path
      fill_in_sign_up(user)
      fill_in 'user_profile', with: ''
      expect { click_button '新規登録' }.not_to change { User.count }
      expect(page).to have_current_path(user_registration_path)
      expect(page).to have_content('プロフィールを入力してください')
      expect(page).to have_field('user_name', with: user.name)
    end

    it '何も入力しないと登録できない' do
      visit new_user_registration_path
      expect { click_button '新規登録' }.not_to change { User.count }
      expect(page).to have_button('新規登録')
    end
  end

  describe 'ログイン・ログアウト' do
    let!(:saved_user) { create(:user) }

    it 'トップページからログインページへ行き、正しくログインするとトップページに戻る' do
      visit root_path
      click_link 'ログイン'
      expect(page).to have_current_path(new_user_session_path)
      fill_in 'user_email', with: saved_user.email
      fill_in 'user_password', with: saved_user.password
      click_button 'ログイン'
      expect(page).to have_current_path(root_path)
      expect(page).to have_content("こんにちは、#{saved_user.name}さん")
    end

    it '登録されていないメールアドレスではログインできない' do
      visit new_user_session_path
      fill_in 'user_email', with: 'nobody@example.com'
      fill_in 'user_password', with: saved_user.password
      click_button 'ログイン'
      expect(page).to have_current_path(user_session_path)
      expect(page).to have_link('新規登録')
    end

    it 'パスワードが違うとログインできない' do
      visit new_user_session_path
      fill_in 'user_email', with: saved_user.email
      fill_in 'user_password', with: 'wrong999'
      click_button 'ログイン'
      expect(page).to have_current_path(user_session_path)
      expect(page).to have_no_button('ログアウト')
    end

    it '空のままではログインできない' do
      visit new_user_session_path
      click_button 'ログイン'
      expect(page).to have_current_path(user_session_path)
      expect(page).to have_no_button('ログアウト')
    end

    it 'トップページからログアウトでき、ヘッダーが「ログイン」「新規登録」に戻る' do
      sign_in(saved_user)
      click_button 'ログアウト'
      expect(page).to have_current_path(root_path)
      expect(page).to have_link('ログイン')
      expect(page).to have_link('新規登録')
      expect(page).to have_no_content('こんにちは')
    end
  end

  describe 'トップページの表示' do
    it 'ログインしていないときは「こんにちは」が出ず、ヘッダーは「ログイン」「新規登録」' do
      visit root_path
      expect(page).to have_no_content('こんにちは')
      expect(page).to have_link('ログイン')
      expect(page).to have_link('新規登録')
      expect(page).to have_no_link('New Proto')
    end
  end

  describe 'ユーザー詳細ページ' do
    let!(:owner) { create(:user) }
    let!(:prototype) { create(:prototype, user: owner) }
    let!(:other_prototype) { create(:prototype) }

    it 'ログインしていなくても見られ、名前・プロフィール・所属・役職とそのユーザーの投稿だけが表示される' do
      visit user_path(owner)
      expect(page).to have_content("#{owner.name}さんの情報")
      expect(page).to have_content(owner.profile)
      expect(page).to have_content(owner.occupation)
      expect(page).to have_content(owner.position)
      expect(page).to have_content("#{owner.name}さんのプロトタイプ")
      expect(page).to have_link(prototype.title)
      expect(page).to have_selector("img[src*='test_image.png']")
      expect(page).to have_no_link(other_prototype.title)
    end

    it 'トップページの投稿者名から移動できる' do
      visit root_path
      click_link "by #{owner.name}"
      expect(page).to have_current_path(user_path(owner))
    end

    it 'プロトタイプ詳細ページの投稿者名から移動できる' do
      visit prototype_path(prototype)
      click_link "by #{owner.name}"
      expect(page).to have_current_path(user_path(owner))
    end

    it 'トップページの「こんにちは、〇〇さん」から自分のページへ移動できる' do
      sign_in(owner)
      click_link "#{owner.name}さん"
      expect(page).to have_current_path(user_path(owner))
    end
  end
end
