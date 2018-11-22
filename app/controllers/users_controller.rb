class UsersController < ApplicationController

  # def index

  # end

  # def new
  #   @user = User.new
  # end

  # def create
  #   @user = User.new(user_params)
  # end

  def show
    @user = current_user
    @user = User.find(params[:id])
    @trackings = @user.trackings
  end

  # def destroy
  # end

  def edit
    @user = current_user
  end

  def update
    @user = current_user
    @user.update(user_params)
  end

private
 def user_params
  params.require(:user).permit(:name, :email, :photo, :password)
 end


end

