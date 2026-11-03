class UsersController < ApplicationController
  def show
    @user = User.find(params[:id])
    @prototypes = @user.prototypes.includes(:user).with_attached_image.order(created_at: :desc)
  end
end
