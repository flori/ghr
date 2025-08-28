# Namespace for notifier-related functionality.
#
# This module serves as a container for notifier plugins and related
# configurations. It provides the foundational structure for implementing
# different notification mechanisms such as email and JIRA integration.
#
# @see GithubReleaseEmailNotifier
# @see GithubReleaseJIRANotifier
module Notifier
  enum :Plugin do
    Email('Notify about new releases via E-Mail')
    JIRA('Notify about new releases via JIRA')

    # @return [String] the description associated with this notifier plugin
    attr_reader :description

    # @param description [String] the description to assign to this notifier
    # plugin
    def init(description)
      @description = description
    end
  end
end
