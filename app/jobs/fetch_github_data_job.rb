class FetchGithubDataJob < ApplicationJob
  queue_as :low_priority

  def perform(*args)
    Settings.projects.each do |project|
      x = Github.get_pull_requests( project.ref )
      if project.environments
        project.environments.each do |environment|
          id = Github.action_name_to_id( project.ref , environment.deployment_workflow  )
          x = Github.get_workflow_runs(  project.ref , id)
        end
      end
    end
  end
end
