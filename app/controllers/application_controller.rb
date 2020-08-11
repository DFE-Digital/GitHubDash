class ApplicationController < ActionController::Base
    protect_from_forgery with: :exception
    helper_method :current_user

    private

    def current_user
      @current_user = session[ "data" ]
    rescue
      @current_user = nil
    end

end
