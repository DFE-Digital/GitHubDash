class FetchGithubDataJob < ApplicationJob
  queue_as :low_priority

  def perform(*args)
    Settings.projects.each do |project|
      x = Github.get_pull_requests( nil,  project.ref )
      if project.environments
        project.environments.each do |environment|
          id = Github.action_name_to_id( nil, project.ref , environment.deployment_workflow  )
          x = Github.get_workflow_runs(  nil, project.ref , id)
        end
      end
    end
  end
end
