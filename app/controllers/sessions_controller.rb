class SessionsController < ApplicationController
  def create
    auth = request.env["omniauth.auth"]
    print( auth.inspect )
    # auth['credentials']['token']
    # auth["info"]["name"]
    @current_user = auth
    session[ "data" ] = auth
    redirect_to root_url, :notice => "Signed in!"
  end

  def failure
    render :text => "Sorry, but you didn't allow access to our app!"
  end

 def destroy
     @current_user = nil
     session["data"] = nil
     redirect_to root_url, :notice => "Signed out!"
 end

end
