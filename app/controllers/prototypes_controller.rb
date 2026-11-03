class PrototypesController < ApplicationController
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

  private

  def prototype_params
    params.require(:prototype).permit(:title, :catch_copy, :concept, :image).merge(user_id: current_user.id)
  end
end
