class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :find_user

  def render_404
    # DPR: this will actually render a 404 page in production
    raise ActionController::RoutingError.new("Not Found")
  end

  def require_login
    @login_user = User.find_by(id: session[:user_id])

    # if @login_user.nil?
    #   flash[:error] = "You must be logged in to view this page!"
    #   redirect_to root_path
    # elsif (1 <= params[:id].to_i) && (params[:id].to_i <= User.all.length) && params[:id] != @login_user.id.to_s
    #   flash[:error] = "Must be this merchant to view page!"
    #   redirect_to root_path
    # end
  end

  private

  def find_user
    if session[:user_id]
      @login_user = User.find_by(id: session[:user_id])
    end
  end
end
