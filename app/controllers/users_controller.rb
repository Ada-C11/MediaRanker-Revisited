
class UsersController < ApplicationController
  # before_action :require_login, except: [:root]

  def index
    @users = User.all
  end

  def show
    @user = User.find_by(id: params[:id])
    if @user.nil?
      flash[:error] = "Couldn't find user!"
      redirect_to users_path
    end
  end

  # def login_form
  # end

  def create
    auth_hash = request.env["omniauth.auth"]

    user = User.find_by(uid: auth_hash[:uid], provider: "github")
    if user
      # User was found in the database
      flash[:success] = "Logged in as returning user, #{user.username}"
    else
      # User doesn't match anything in the DB
      # Attempt to create a new user
      user = User.build_from_github(auth_hash)

      if user.save
        flash[:success] = "Logged in as new user #{user.username}"
      else
        # Couldn't save the user for some reason. If we
        # hit this it probably means there's a bug with the
        # way we've configured GitHub. Our strategy will
        # be to display error messages to make future
        # debugging easier.
        flash[:error] = "Could not create new user account: #{user.errors.messages}"
        return redirect_to root_path
      end
    end

    # If we get here, we have a valid user instance
    session[:user_id] = user.id
    return redirect_to root_path
  end

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

  def current
    user = User.find_by(uid: session[:user_id])
    if @user.nil?
      flash[:error] = "You must be logged in first!"
      redirect_to root_path
    end
  end

  def destroy
    user = User.find_by(id: session[:user_id])
    if user.nil?
      flash[:error] = "There is not a logged in user."
    end
    session[:user_id] = nil
    flash[:success] = "Successfully logged out. Bye, #{user.username}!"
    redirect_to root_path
  end
end
