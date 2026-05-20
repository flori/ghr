# Controller for managing GitHub repository endpoints.
#
# This controller handles requests related to GitHub repositories, providing
# functionality to list all tracked repositories.
#
# @example
#   GET /repos - Returns a JSON array of all tracked repositories
class ReposController < ApplicationController
  include ActionController::MimeResponds

  # Returns a JSON representation of the GithubRepo models as an array of
  # objects.
  def index
    render json: GithubRepo.order(:user, :repo).all.map { |github_repo|
      {
        url:                  repo_releases_url(github_repo.to_param),
        atom_url:             repo_releases_url(github_repo.to_param, format: :atom),
        releases_count:       github_repo.github_releases.count,
        user:                 github_repo.user,
        repo:                 github_repo.repo,
        tag_filter:           github_repo.tag_filter,
        version_requirement:  github_repo.version_requirement,
        lightweight:          github_repo.lightweight,
        import_enabled:       github_repo.import_enabled,
        configured_notifiers: github_repo.configured_notifiers.map(&:name),
        created_at:           github_repo.created_at,
        updated_at:           github_repo.updated_at,
      }
    }
  end
end
