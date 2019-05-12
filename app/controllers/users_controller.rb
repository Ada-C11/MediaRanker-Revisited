class UsersController < ApplicationController
  def index
    @users = User.all
  end

  def show
    @user = User.find_by(id: params[:id])
    render_404 unless @user
  end

  def login
    auth_hash = request.env["omniauth.auth"]

    user = User.find_by(id: auth_hash[:uid], provider: "github")
    if user
      flash[:success] = "Logged in as returning user #{user.username}"
    else
      user = User.build_from_github(auth_hash)

      if user.save
        flash[:success] = "Logged in as new user #{user.username}"
      else
        flash[:status] = :failure
        flash[:result_text] = "Could not create new user account."
        return redirect_to root_path
      end
    end

    session[:user_id] = user.id
    return redirect_to root_path
  end

  def current
    @current_user = User.find_by(id: session[:user_id])
    if @current_user.nil?
      flash[:error] = "You must be logged in first!"
      redirect_to users_path
    end
  end

  def destroy
    user = User.find_by(id: session[:user_id])
    session[:user_id] = nil
    flash[:notice] = "Logged out #{user.username}"
    redirect_to root_path
  end
end
