require 'rails_helper'

RSpec.describe Prototype, type: :model do
  let(:prototype) { build(:prototype) }

  describe 'プロトタイプの投稿' do
    context '投稿できるとき' do
      it '名称・キャッチコピー・コンセプト・画像がそろえば投稿できる' do
        expect(prototype).to be_valid
      end
    end

    context '投稿できないとき' do
      it '名称が空では投稿できない' do
        prototype.title = ''
        prototype.valid?
        expect(prototype.errors.full_messages).to include('プロトタイプの名称を入力してください')
      end

      it 'キャッチコピーが空では投稿できない' do
        prototype.catch_copy = ''
        prototype.valid?
        expect(prototype.errors.full_messages).to include('キャッチコピーを入力してください')
      end

      it 'コンセプトが空では投稿できない' do
        prototype.concept = ''
        prototype.valid?
        expect(prototype.errors.full_messages).to include('コンセプトを入力してください')
      end

      it '画像がないと投稿できない' do
        prototype.image = nil
        prototype.valid?
        expect(prototype.errors.full_messages).to include('プロトタイプの画像を入力してください')
      end

      it 'ユーザーが紐づいていないと投稿できない' do
        prototype.user = nil
        prototype.valid?
        expect(prototype.errors.full_messages).to include('投稿者を入力してください')
      end
    end
  end

  describe 'プロトタイプの削除' do
    it 'プロトタイプを消すと、ついているコメントも消える' do
      prototype.save!
      create(:comment, prototype: prototype)
      expect { prototype.destroy }.to change { Comment.count }.by(-1)
    end
  end
end
