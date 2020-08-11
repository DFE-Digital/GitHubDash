class SessionsController < ApplicationController
  def create
    auth = request.env["omniauth.auth"]
    user = User.find_and_refresh(auth)
    @current_user = user
    session[:user_id] = user.uid
    redirect_to root_url, :notice => "Signed in!"
  end

 def destroy
     @current_user = nil
     session[:user_id] = nil
     redirect_to root_url, :notice => "Signed out!"
 end

end
