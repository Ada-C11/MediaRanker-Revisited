class UsersController < ApplicationController
  before_action :find_logged_in_user, only: [:index, :show]
  def index
    if @logged_in_user
      @users = User.all
    else
      flash[:status] = :failure
      flash[:result_text] = "You must log in to do that"
      redirect_to root_path
    end
  end

  def show
    if @logged_in_user
    @user = User.find_by(id: params[:id])
    render_404 unless @user
  else
    flash[:status] = :failure
    flash[:result_text] = "You must log in to do that"
    redirect_to root_path
  end
  end

  def create
    auth_hash = request.env["omniauth.auth"]
    user = User.find_by(uid: auth_hash["uid"])
    if user
      session[:user_id] = user.id
      flash[:status] = :success
      flash[:result_text] = "Successfully logged in as existing user #{user.username}"
    else
      user = User.build_from_github(auth_hash)
      if user.save
        session[:user_id] = user.id
        flash[:status] = :success
        flash[:result_text] = "Successfully created new user #{user.username} with ID #{user.id}"
      else
        flash.now[:status] = :failure
        flash.now[:result_text] = "Could not log in"
        flash.now[:messages] = user.errors.messages
        render "login_form", status: :bad_request
        return
      end
    end
    redirect_to root_path
  end

  def destroy
    if session[:user_id]
      session[:user_id] = nil
      flash[:status] = :success
      flash[:result_text] = "Successfully logged out"
    else
      flash[:status] = :failure
      flash[:result_text] = "No logged in user to logout"
    end

    redirect_to root_path
  end
end
