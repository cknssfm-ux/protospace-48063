require 'rails_helper'

RSpec.describe 'コメント投稿機能', type: :system do
  let(:user) { create(:user) }
  let!(:prototype) { create(:prototype) }

  it 'ログインしていると詳細ページからコメントでき、投稿者名つきで表示される' do
    sign_in(user)
    visit prototype_path(prototype)
    fill_in 'comment_content', with: 'いいアイデアですね'
    expect { click_button '送信する' }.to change { Comment.count }.by(1)
    expect(page).to have_current_path(prototype_path(prototype))
    expect(page).to have_content('いいアイデアですね')
    expect(page).to have_link("（#{user.name}）")
  end

  it 'コメントの投稿者名からユーザー詳細ページへ行ける' do
    create(:comment, prototype: prototype, user: user, content: '感想です')
    visit prototype_path(prototype)
    click_link "（#{user.name}）"
    expect(page).to have_current_path(user_path(user))
  end

  it '空のままでは投稿できず、詳細ページの表示のまま留まる' do
    sign_in(user)
    visit prototype_path(prototype)
    expect { click_button '送信する' }.not_to change { Comment.count }
    expect(page).to have_content('コメントを入力してください')
    expect(page).to have_content(prototype.title)
    expect(page).to have_button('送信する')
  end

  it 'ログインしていないとコメントのフォームは表示されない' do
    create(:comment, prototype: prototype, content: 'みんなに見えるコメント')
    visit prototype_path(prototype)
    expect(page).to have_no_field('comment_content')
    expect(page).to have_no_button('送信する')
    expect(page).to have_content('みんなに見えるコメント')
  end
end
