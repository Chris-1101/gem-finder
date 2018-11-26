class TrackingsController < ApplicationController
  def index
    @user = User.find(params[:user_id])
    @trackings = @user.properties
  end

  def destroy
    @tracking = Tracking.find(params[:id])
    @tracking.destroy
    @user = current_user
    redirect_to user_path(@user)
  end

  def create
    tracking = Tracking.new(tracking_params)
    @user = current_user
    if tracking.save
      redirect_to user_path(@user)
    end
  end

  private
  def tracking_params
    params.require(:tracking).permit(:user_id, :property_id)
  end
end
