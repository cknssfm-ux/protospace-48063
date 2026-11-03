class PrototypesController < ApplicationController
  before_action :set_prototype, only: [:show, :edit, :update]

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

  private

  def prototype_params
    params.require(:prototype).permit(:title, :catch_copy, :concept, :image).merge(user_id: current_user.id)
  end

  def set_prototype
    @prototype = Prototype.find(params[:id])
  end
end
