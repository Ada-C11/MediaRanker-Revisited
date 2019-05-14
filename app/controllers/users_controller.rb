class UsersController < ApplicationController
  def index
    @users = User.all
  end

  def show
    @user = User.find_by(id: params[:id])
    render_404 unless @user
  end

  def create
    auth_hash = request.env["omniauth.auth"]

    user = User.get_authorized_user(auth_hash)

    if user.save
      flash[:status] = :success
      flash[:result_text] = "Successfully logged in as #{user.name}"
      session[:user_id] = user.id
    else
      flash[:status] = :warning
      flash[:result_text] = "Could not log in #{user.name}"
    end
    redirect_to root_path
  end

  def destroy
    session[:user_id] = nil
    flash[:status] = :success
    flash[:result_text] = "Successfully logged out"
    redirect_to root_path
  end
end
