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
    # raise
    user = User.find_by(uid: auth_hash[:uid], provider: auth_hash[:provider])

    if user
      flash[:result_text] = "Welcome back #{user.name}!"
    else
      user = User.generate_user(auth_hash)
      if user.save
        flash[:result_text] = "Welcome #{user.name}, you are now logged in."
      else
        flash[:result_text] = "Login unsuccessful: #{user.errors.messages}"
        return redirect_to root_path
      end
    end

    session[:user_id] = user.id
    return redirect_to root_path
  end

  def destroy
    session[:user_id] = nil
    flash[:result_text] = "Successfully logged out!"

    redirect_to root_path
  end
end
