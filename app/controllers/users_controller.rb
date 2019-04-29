class UsersController < ApplicationController
  def index
    @users = User.all
  end

  def show
    @user = User.find_by(id: params[:id])
    render_404 unless @user
  end

  # def login_form
  # end

  # def login
  #   username = params[:username]
  #   if username and user = User.find_by(username: username)
  #     session[:user_id] = user.id
  #     flash[:status] = :success
  #     flash[:result_text] = "Successfully logged in as existing user #{user.username}"
  #   else
  #     user = User.new(username: username)
  #     if user.save
  #       session[:user_id] = user.id
  #       flash[:status] = :success
  #       flash[:result_text] = "Successfully created new user #{user.username} with ID #{user.id}"
  #     else
  #       flash.now[:status] = :failure
  #       flash.now[:result_text] = "Could not log in"
  #       flash.now[:messages] = user.errors.messages
  #       render "login_form", status: :bad_request
  #       return
  #     end
  #   end
  #   redirect_to root_path
  # end

  # def logout
  #   session[:user_id] = nil
  #   flash[:status] = :success
  #   flash[:result_text] = "Successfully logged out"
  #   redirect_to root_path
  # end

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
        flash.now[:status] = :failure
        flash.now[:result_text] = "Could not create new user account: #{@login_user.errors.messages}"
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
