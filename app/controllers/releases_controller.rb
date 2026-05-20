# Controller for managing GitHub releases for a specific repository.
#
# This controller provides functionality to list releases for a given repository,
# supporting both JSON and Atom feed formats.
#
# @example
#   GET /repos/user:repo/releases - Returns a JSON array of releases or an Atom feed
class ReleasesController < ApplicationController
  include ActionController::MimeResponds

  # Returns the releases for the repo given as +param[:repo_id]+ in the form of
  # +"user:repo"+. If there are no releases, an HTTP 404 status code is
  # returned. If there are releases, an HTTP 200 status code is returned and
  # for format +:atom+ the atom feed of releases is returned, for any other
  # format this is a JSON array of objects containing the releases.
  def index
    github_repo = GithubRepo.find_by_param(params[:repo_id])
    unless github_repo
      render status: :not_found
      return
    end
    releases = github_repo.github_releases.sort_by(&:version).reverse.limitate(params)
    respond_to do |format|
      format.atom do
        if releases.empty?
          render status: :not_found
        else
          render plain: AtomBuilder.new(releases, host: request.host).to_atom
        end
      end
      format.any do
        render json: {
          releases: releases.map(&:as_json),
          offset:   releases.limitate_offset,
          limit:    releases.limitate_limit,
          total:    releases.limitate_total,
        }
      end
    end
  end
end
