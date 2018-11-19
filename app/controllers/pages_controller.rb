class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:home]

  def home
  end

  def properties
  end

  def about
  end

  def contact
  end


end
