class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :find_user

  def render_404
    # DPR: this will actually render a 404 page in production
    raise ActionController::RoutingError.new("Not Found")
  end

  private

  # hmmm saw this method on refactor, going to keep using the method I created... ¯\_(ツ)_/¯
  # adding to wishlist to comeback and use this one instead.
  def find_user
    if session[:user_id]
      @login_user = User.find_by(id: session[:user_id])
    end
  end

  def find_logged_in_user
    @logged_in_user = User.find_by(id: session[:user_id])
  end
end
