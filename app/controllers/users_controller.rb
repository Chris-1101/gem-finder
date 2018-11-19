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
  end

  # def destroy
  # end

  # def edit
  # end

  # def update
  # end
end

