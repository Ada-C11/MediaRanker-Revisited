class UsersController < ApplicationController
  def index
    if @login_user.nil?
      flash[:status] = :failure
      flash[:result_text] = "You must be logged in to see this page!"
      return redirect_to root_path
    end

    @users = User.all
  end

  def show
    if @login_user.nil?
      flash[:status] = :failure
      flash[:result_text] = "You must be logged in to see this page!"
      return redirect_to root_path
    end

    @user = User.find_by(id: params[:id])
    render_404 unless @user
  end

  def create
    auth_hash = request.env["omniauth.auth"]
    user = User.find_by(uid: auth_hash[:uid], provider: "github")

    if user
      flash[:status] = :success
      flash[:result_text] = "Logged in as returning user #{user.name}"
    else
      user = User.build_from_github(auth_hash)
      if user.save
        flash[:status] = :success
        flash[:result_text] = "Logged in as new user #{user.name}"
      else
        flash[:result_text] = "Could not create new user account: "
        flash[:messages] = user.errors.messages
        return redirect_to root_path
      end
    end

    session[:user_id] = user.id
    return redirect_to root_path
  end

  def destroy
    session[:user_id] = nil
    flash[:status] = :success
    flash[:result_text] = "Successfully logged out!"

    redirect_to root_path
  end

  def current
    @user = User.find_by(id: session[:user_id])
    if @user.nil?
      flash[:result_text] = "User not found: "
      flash[:messages] = @user.errors.messages
      redirect_to root_path
    end
  end
end
