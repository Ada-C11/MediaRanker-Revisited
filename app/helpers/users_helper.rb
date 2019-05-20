module UsersHelper
  def find_user
    if session[:user_id]
      @login_user = User.find_by(id: session[:user_id])
    end
  end

  def correct_user?(work)
    work.user_id == find_user.id
  end
end
