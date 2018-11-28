class UsersController < ApplicationController

  def show
    @user = current_user
    # @user = User.find(params[:id])
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
