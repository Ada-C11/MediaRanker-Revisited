class UsersController < ApplicationController
  def index
    @users = User.all
  end

  def show
    @user = User.find_by(id: params[:id])
    render_404 unless @user
  end

  def login_form
  end

  def create
    auth_hash = request.env["omniauth.auth"]
    user = User.find_by(uid: auth_hash[:uid], provider: "github")
    if user
      flash[:status] = :success
      flash[:result_text] = "Logged in as returning user #{user.username}"
    else
      user = User.make_from_github(auth_hash)
      if user.save
        flash[:status] = :success
        flash[:result_message] = "Logged in as new user #{user.username}"
      else
        flash[:status] = :error
        flash[:result_text] = "Couldn't create new user account"
        flash[:messages] = user.errors.messages
        return redirect_to root_path
      end
    end
    #valid user?
    session[:user_id] = user.id
    return redirect_to root_path
  end

  def destroy
    session[:user_id] = nil
    flash[:status] = :success
    flash[:result_text] = "Successfully logged out"

    redirect_to root_path
  end
end
