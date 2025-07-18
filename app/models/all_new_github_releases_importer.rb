class AllNewGithubReleasesImporter
  # Import all {GithubRepo}s where +import_enabled+ is set to true.
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
