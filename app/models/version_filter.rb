class VersionFilter
  # @!method self.for_github_repo(github_repo)
  #   Returns a new instance of the tagger that uses the provided GitHub repository.
  #   @param [GithubRepo] github_repo The GitHub repository to be used.
  #   @return [VersionFilter] A new instance of VersionFilter.
  def self.for_github_repo(github_repo)
    new(
      github_repo.tag_filter.presence || '.*',
      github_repo.version_requirement
    )
  end

  # @param [Regexp,String] tag_filter
  # @param [String] version_requirement
  def initialize(tag_filter, version_requirement)
    @tag_filter_re =
      if tag_filter.is_a? Regexp
        tag_filter
      else
        Regexp.new(tag_filter)
      end
    @version_requirement =
      if version_requirement.present?
        Gem::Requirement.new(version_requirement)
      end
  end

  # @param [String] tag_name
  # @return [Boolean] true if the +tag_name+ was matched and the +version_requirement+ was fullfilled.
  def match(tag_name)
    match = @tag_filter_re.match(tag_name) or return false
    # The first group or the total regexp match:
    if @version_requirement
      version = Gem::Version.new(match&.captures&.join(?.).presence || match[0])
      return @version_requirement.satisfied_by?(version)
    end
    true
  end
  alias === match
  alias =~ match
end
