class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :find_user

  def render_404
    # DPR: this will actually render a 404 page in production
    raise ActionController::RoutingError.new("Not Found")
  end

  def require_login
    find_user

    if @login_user.nil?
      flash[:status] = :failure
      flash[:result_text] = "You must be logged in to view this section"
      redirect_back(fallback_location: root_path)
      return false
    end

    return true
  end

  private

  def find_user
    if session[:user_id]
      @login_user = User.find_by(id: session[:user_id])
    end
  end
end
