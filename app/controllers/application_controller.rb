class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :find_user

  def render_404
    # DPR: this will actually render a 404 page in production
    raise ActionController::RoutingError.new("Not Found")
  end

  private

  def find_user
    if session[:user_id]
      @login_user = User.find_by(id: session[:user_id])
    end
  end

  def not_logged_in
    if session[:user_id].nil?
      redirect_to root_path
      flash[:status] = :failure
      flash[:result_text] = "you have to be logged in to see this!"
    end
  end

  # def user_creater
  # if session[:user_id] != Work.find_by(id: params[:id]).user.id raise
  # end
end
