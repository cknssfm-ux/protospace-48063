class CommentsController < ApplicationController
  # コメントはログインしている人だけ
  before_action :authenticate_user!

  def create
    @comment = Comment.new(comment_params)
    if @comment.save
      redirect_to prototype_path(@comment.prototype)
    else
      # 保存できなかったときは、プロトタイプの詳細ページをそのまま表示し直す
      @prototype = Prototype.find(params[:prototype_id])
      @comments = @prototype.comments.includes(:user)
      render "prototypes/show", status: 422
    end
  end

  private

  def comment_params
    params.require(:comment).permit(:content).merge(user_id: current_user.id, prototype_id: params[:prototype_id])
  end
end
