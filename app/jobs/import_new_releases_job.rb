# Job responsible for triggering the process of importing new GitHub releases.
# This job is typically scheduled to run periodically via Solid Queue.
class ImportNewReleasesJob < ApplicationJob
  queue_as :default

  # Executes the import logic by delegating to the
  # `AllNewGithubReleasesImporter` service.
  def perform
    AllNewGithubReleasesImporter.new.perform
  end
end
