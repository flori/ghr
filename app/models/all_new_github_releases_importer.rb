# Imports all GitHub releases for repositories with import enabled.
#
# This class is responsible for performing the import of new GitHub releases
# across all configured repositories where the +import_enabled+ flag is set to
# true. It iterates through each such repository and triggers the import
# process, logging the progress and handling any errors that may occur during
# the import.
#
# @example
#   importer = AllNewGithubReleasesImporter.new
#   importer.perform
class AllNewGithubReleasesImporter

  # Performs the import of new GitHub releases for all repositories with import
  # enabled.
  #
  # This method iterates through all GitHub repositories that have the import
  # enabled flag set to true. For each repository, it initiates the import
  # process of new releases using the GithubReleaseImporter. It logs the
  # progress of the import process including the number of releases imported
  # for each repository and any errors encountered during the import.
  def perform
    Rails.logger.info "Starting to import new releases…"
    GithubRepo.where(import_enabled: true).find_each do |github_repo|
      if count = GithubReleaseImporter.new(github_repo:, notify: github_repo.import_enabled).perform
        Rails.logger.info "Imported #{count} releases for #{github_repo.to_param}."
      end
    rescue => e
      Rails.logger.error "Error #{e.class} #{e.to_s.inspect} while importing releases for #{github_repo.to_param}."
      Rails.logger.error e
    end
    Rails.logger.info "Finished importing new releases!"
  end
end
