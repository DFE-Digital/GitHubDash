class SessionsController < ApplicationController
  def create
    auth = request.env["omniauth.auth"]
    # auth['credentials']['token']
    # auth["info"]["name"]
    @current_user = auth
    session[ "data" ] = auth
    redirect_to root_url, :notice => "Signed in!"
  end

 def destroy
     @current_user = nil
     session["data"] = nil
     redirect_to root_url, :notice => "Signed out!"
 end

end
