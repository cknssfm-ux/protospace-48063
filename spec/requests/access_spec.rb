require 'rails_helper'

# 画面にボタンがなくても、URL を直接送られたときに守れているかを確かめる
RSpec.describe 'アクセスの制限', type: :request do
  let(:owner) { create(:user) }
  let(:other_user) { create(:user) }
  let!(:prototype) { create(:prototype, user: owner) }
  let(:new_params) { { prototype: { title: '書き換え', catch_copy: 'c', concept: 'k' } } }

  describe 'ログインしていないとき' do
    it 'トップページ・詳細ページ・ユーザー詳細・新規登録・ログインは見られる' do
      [root_path, prototype_path(prototype), user_path(owner), new_user_registration_path, new_user_session_path].each do |path|
        get path
        expect(response).to have_http_status(200), "#{path} が 200 ではない"
      end
    end

    it '新規投稿ページはログインページへ' do
      get new_prototype_path
      expect(response).to redirect_to(new_user_session_path)
    end

    it '投稿（create）はできずログインページへ' do
      expect { post prototypes_path, params: new_params }.not_to change { Prototype.count }
      expect(response).to redirect_to(new_user_session_path)
    end

    it '編集ページはログインページへ' do
      get edit_prototype_path(prototype)
      expect(response).to redirect_to(new_user_session_path)
    end

    it '更新はできずログインページへ' do
      patch prototype_path(prototype), params: new_params
      expect(response).to redirect_to(new_user_session_path)
      expect(prototype.reload.title).not_to eq('書き換え')
    end

    it '削除はできずログインページへ' do
      expect { delete prototype_path(prototype) }.not_to change { Prototype.count }
      expect(response).to redirect_to(new_user_session_path)
    end

    it 'コメントはできずログインページへ' do
      expect { post prototype_comments_path(prototype), params: { comment: { content: 'x' } } }.not_to change { Comment.count }
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe '投稿者以外がログインしているとき' do
    before { sign_in_as(other_user) }

    it '編集ページはトップページへ' do
      get edit_prototype_path(prototype)
      expect(response).to redirect_to(root_path)
    end

    it '更新はできずトップページへ' do
      patch prototype_path(prototype), params: new_params
      expect(response).to redirect_to(root_path)
      expect(prototype.reload.title).not_to eq('書き換え')
    end

    it '削除はできずトップページへ' do
      expect { delete prototype_path(prototype) }.not_to change { Prototype.count }
      expect(response).to redirect_to(root_path)
    end
  end

  describe '投稿者本人がログインしているとき' do
    before { sign_in_as(owner) }

    it '編集ページが開ける' do
      get edit_prototype_path(prototype)
      expect(response).to have_http_status(200)
    end

    it '空の項目で更新すると 422 で編集ページを出し直す' do
      patch prototype_path(prototype), params: { prototype: { title: '' } }
      expect(response).to have_http_status(422)
      expect(response.body).to include('プロトタイプ編集')
    end
  end

  # devise のログインを、ログインフォームへの POST で行う
  def sign_in_as(user)
    post user_session_path, params: { user: { email: user.email, password: user.password } }
    expect(response).to redirect_to(root_path)
  end
end
