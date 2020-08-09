class SessionsController < ApplicationController
  def create
    auth = request.env["omniauth.auth"]
    user = User.find_and_refresh(auth)
    session[:user_id] = user.uid
    redirect_to root_url, :notice => "Signed in!"
 end

 def destroy
     session[:user_id] = nil
     redirect_to root_url, :notice => "Signed out!"
 end


  def new
  end

  def failure
  end
end
