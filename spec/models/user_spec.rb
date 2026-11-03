require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) { build(:user) }

  describe 'ユーザー新規登録' do
    context '登録できるとき' do
      it 'すべての項目が正しく入っていれば登録できる' do
        expect(user).to be_valid
      end

      it 'パスワードが6文字なら登録できる' do
        user.password = user.password_confirmation = 'abc123'
        expect(user).to be_valid
      end
    end

    context '登録できないとき' do
      it 'メールアドレスが空では登録できない' do
        user.email = ''
        user.valid?
        expect(user.errors.full_messages).to include('メールアドレスを入力してください')
      end

      it '同じメールアドレスは登録できない' do
        create(:user, email: 'same@example.com')
        user.email = 'same@example.com'
        user.valid?
        expect(user.errors.full_messages).to include('メールアドレスはすでに使われています')
      end

      it 'メールアドレスに@がないと登録できない' do
        user.email = 'testexample.com'
        user.valid?
        expect(user.errors.full_messages).to include('メールアドレスは正しくありません')
      end

      it 'パスワードが空では登録できない' do
        user.password = user.password_confirmation = ''
        user.valid?
        expect(user.errors.full_messages).to include('パスワードを入力してください')
      end

      it 'パスワードが5文字以下では登録できない' do
        user.password = user.password_confirmation = 'ab123'
        user.valid?
        expect(user.errors.full_messages).to include('パスワードは6文字以上で入力してください')
      end

      it 'パスワードと確認用が一致しないと登録できない' do
        user.password_confirmation = 'abc1234'
        user.valid?
        expect(user.errors.full_messages).to include('パスワード（確認用）とパスワードの入力が一致しません')
      end

      it 'ユーザー名が空では登録できない' do
        user.name = ''
        user.valid?
        expect(user.errors.full_messages).to include('ユーザー名を入力してください')
      end

      it 'プロフィールが空では登録できない' do
        user.profile = ''
        user.valid?
        expect(user.errors.full_messages).to include('プロフィールを入力してください')
      end

      it '所属が空では登録できない' do
        user.occupation = ''
        user.valid?
        expect(user.errors.full_messages).to include('所属を入力してください')
      end

      it '役職が空では登録できない' do
        user.position = ''
        user.valid?
        expect(user.errors.full_messages).to include('役職を入力してください')
      end
    end
  end
end
