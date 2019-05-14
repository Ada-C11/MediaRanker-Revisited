class ApplicationController < ActionController::Base
  
  before_action :find_user
  before_action :require_login

  def find_user
    if session[:user_id]
      @login_user = User.find_by(id: session[:user_id])
    end
  end

  def require_login
    current_user = find_user
    if current_user.nil?
      flash[:result_text] = "You must be logged in to view this section."
      redirect_to root_path
    end
  end

  def render_404
    # DPR: this will actually render a 404 page in production
    raise ActionController::RoutingError.new("Not Found")
  end
end
