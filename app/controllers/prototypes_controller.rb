class PrototypesController < ApplicationController
  # ログインしていない人は、一覧と詳細以外ではログインページへ
  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_prototype, only: [:show, :edit, :update, :destroy]
  # 投稿した本人以外は、編集・更新・削除をさせずにトップページへ
  before_action :move_to_index, only: [:edit, :update, :destroy]

  def index
    @prototypes = Prototype.includes(:user).with_attached_image.order(created_at: :desc)
  end

  def new
    @prototype = Prototype.new
  end

  def create
    @prototype = Prototype.new(prototype_params)
    if @prototype.save
      redirect_to root_path
    else
      # 入力した文字は @prototype に残っているので、フォームに戻しても消えない（画像だけは選び直し）
      render :new, status: 422
    end
  end

  def show
    @comment = Comment.new
    @comments = @prototype.comments.includes(:user)
  end

  def edit
  end

  def update
    # 画像を選ばずに保存したときは、今の画像がそのまま残る
    if @prototype.update(prototype_params)
      redirect_to prototype_path(@prototype)
    else
      render :edit, status: 422
    end
  end

  def destroy
    @prototype.destroy
    redirect_to root_path
  end

  private

  def prototype_params
    params.require(:prototype).permit(:title, :catch_copy, :concept, :image).merge(user_id: current_user.id)
  end

  def set_prototype
    @prototype = Prototype.find(params[:id])
  end

  def move_to_index
    redirect_to root_path unless current_user.id == @prototype.user_id
  end
end
