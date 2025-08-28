# Controller for managing GitHub repository endpoints.
#
# This controller handles requests related to GitHub repositories, providing
# functionality to list all tracked repositories and retrieve information about
# specific repositories, including their releases and associated data. It
# supports both JSON and Atom feed formats for repository details and
# release information.
#
# @example
#   GET /repos - Returns a JSON array of all tracked repositories
#   GET /repos/:id - Returns release information for a specific repository
#   GET /repos/:id.atom - Returns an Atom feed of releases for a repository
class ReposController < ApplicationController
  include ActionController::MimeResponds

  # Returns a JSON representation of the GithubRepo models as an array of
  # objects.
  def index
    render json: GithubRepo.order(:user, :repo).all.map { |github_repo|
      {
        url:                  repo_url(github_repo.to_param),
        atom_url:             repo_url(github_repo.to_param, format: :atom),
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


  # Returns the release for the repo given as +param[:id]+ in the form of
  # +"user:repo"+. If there are no releases, an HTTP 404 status code is
  # returned. If there are releases, an HTTP 200 status code is returned and
  # for format +:atom+ the atom feed of releases is returned, for any other
  # format this is a JSON array of objects containing the releases.
  def show
    github_repo = GithubRepo.find_by_param(params[:id])
    unless github_repo
      render status: :not_found
      return
    end
    releases = github_repo.github_releases.sort_by do |release|
      release.version(github_repo.tag_filter)
    end.reverse
    respond_to do |format|
      format.atom do
        if releases.empty?
          render status: :not_found
        else
          render plain: AtomBuilder.new(releases, host: request.host).to_atom
        end
      end
      format.any do
        render json: releases.map(&:as_json)
      end
    end
  end
end
