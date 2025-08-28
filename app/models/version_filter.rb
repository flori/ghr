# A filter for GitHub repository tags that incorporates version requirements.
#
# This class provides functionality to match tag names against a specified
# regular expression pattern and verify that the matched versions satisfy given
# version requirements. It is used to determine whether a GitHub release tag
# should be imported based on both its naming convention and version criteria.
#
# @example
#   # Create a version filter for tags matching the pattern v\d+\.\d+\.\d+
#   # and satisfying the version requirement ~> 1.0
#   filter = VersionFilter.new('\\Av(\\d+\\.\\d+\\.\\d+)\\z', ['~> 1.0'])
#
#   # Check if a tag name matches the criteria
#   filter.match('v1.2.3')  # => true
#   filter.match('v2.0.0')  # => false (does not satisfy ~> 1.0)
class VersionFilter
  # Creates a new VersionFilter instance configured from a GithubRepo's
  # settings.
  #
  # This method serves as a factory for creating VersionFilter objects
  # using the tag_filter and version_requirement attributes from a given
  # GithubRepo instance.
  #
  # @param github_repo [GithubRepo] the repository to configure the filter from
  # @return [VersionFilter] a new VersionFilter instance configured with the repo's settings
  def self.for_github_repo(github_repo)
    new(
      github_repo.tag_filter,
      github_repo.version_requirement
    )
  end

  # @param [Regexp,String] tag_filter
  # @param [String] version_requirement
  def initialize(tag_filter, version_requirement)
    @tag_filter = TagFilter.new(tag_filter)
    @version_requirement =
      if version_requirement.present?
        Gem::Requirement.new(version_requirement)
      end
  end

  # @param [String] tag_name
  # @return [Boolean] true if the +tag_name+ was matched and the
  # +version_requirement+ was fullfilled.
  def match(tag_name)
    match = @tag_filter.match(tag_name) or return false
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
