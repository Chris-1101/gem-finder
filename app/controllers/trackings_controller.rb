class TrackingsController < ApplicationController
  def index
    @user = User.find(params[:user_id])
    @trackings = @user.properties
  end

  def destroy
    @user = current_user
    redirect_to user_trackings_path(@user)
  end

  def create
    @tracking = Tracking.create(tracking_params)
    @user = current_user
    redirect_to user_path(@user)
  end

  def tracking_params
    params.require(:tracking).permit(:user_id, :property_id)
  end
end
