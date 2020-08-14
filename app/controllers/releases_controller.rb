class ReleasesController < ApplicationController
  def show () 
     @workflows =  Github.get_workflow_runs(  params[:repo] , params[:id]  , params[:branch] )
  end
end
