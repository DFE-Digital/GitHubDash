require 'pagy/extras/array'
require 'pagy/extras/bulma'

class ReleasesController < ApplicationController
  include Pagy::Backend

  def show () 
     data =  Github.get_workflow_runs(  params[:repo] , params[:id]  , params[:branch] )['workflow_runs']
     @pagy , @workflows = pagy_array( data , page: params[:page] , items: 9 ) 
  end
end
