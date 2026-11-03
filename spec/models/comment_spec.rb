require 'rails_helper'

RSpec.describe Comment, type: :model do
  let(:comment) { build(:comment) }

  describe 'コメントの投稿' do
    it '文字が入っていれば投稿できる' do
      expect(comment).to be_valid
    end

    it '文字が空では投稿できない' do
      comment.content = ''
      comment.valid?
      expect(comment.errors.full_messages).to include('コメントを入力してください')
    end

    it 'プロトタイプが紐づいていないと投稿できない' do
      comment.prototype = nil
      comment.valid?
      expect(comment.errors.full_messages).to include('プロトタイプを入力してください')
    end

    it 'ユーザーが紐づいていないと投稿できない' do
      comment.user = nil
      comment.valid?
      expect(comment.errors.full_messages).to include('投稿者を入力してください')
    end
  end
end
