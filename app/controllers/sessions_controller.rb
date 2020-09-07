class SessionsController < ApplicationController
  def create
    auth = request.env["omniauth.auth"]
    @current_user = auth
    session[ "data" ] = auth
    session[:expires_at] = Time.current + 8.hours
    redirect_to root_url, :notice => "Signed in!"
  end

 def destroy
     @current_user = nil
     session["data"] = nil
     session[:expires_at] = Time.current 
     redirect_to root_url, :notice => "Signed out!"
 end

end
