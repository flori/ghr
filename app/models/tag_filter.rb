class TagFilter
  def initialize(tag_filter)
    tag_filter = tag_filter.presence || '.*'
    @regexp =
      if tag_filter.is_a? Regexp
        tag_filter
      else
        Regexp.new(tag_filter)
      end
  end

  # Matches the given string against the tag_filter regular expression.
  #
  # @param string [String] The input string to match.
  #
  # @return [MatchData, nil] A MatchData object if the string matches the pattern,
  #   or nil otherwise.
  def match(string)
    @regexp.match(string)
  end

  # Returns a Tins::StringVersion::Version object representing the version
  # string, or nil if it's not a valid version.

  # @param string [ String ] The version string to parse.

  # @return [ Tins::StringVersion::Version, NilClass ] A Tins::StringVersion::Version object, or nil.
  def version(string)
    my_match       = match(string) or return
    string_version = my_match&.captures&.join(?.).presence || my_match[0]
    begin
      Tins::StringVersion(string_version)
    rescue ArgumentError
      nil
    end
  end
end
