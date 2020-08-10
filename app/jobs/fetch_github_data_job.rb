class FetchGithubDataJob < ApplicationJob
  queue_as :low_priority

  def perform(*args)
      puts 'Hello world'
  end
end
