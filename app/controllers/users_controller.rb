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

    @login_user = User.find_by(uid: auth_hash[:uid], provider: "github")

    if !@login_user.nil?
      flash[:status] = :success
      flash[:result_text] = "Successfully logged in as existing user #{@login_user.name}"
    else
      @login_user = User.build_from_github(auth_hash)

      if @login_user.save
        flash[:status] = :success
        flash[:result_text] = "Logged in as new user #{@login_user.name}"
      else
        @login_user.errors.messages.each do |field, message|
          flash.now[field] = message
        end
        return redirect_to root_path
      end
    end

    session[:user_id] = @login_user.id
    return redirect_to root_path
  end

  def destroy
    session[:user_id] = nil
    flash[:status] = :success
    flash[:result_text] = "Successfully logged out!"

    redirect_to root_path
  end
end
