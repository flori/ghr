module Notifier
  enum :Plugin do
    Email('Notify about new releases via E-Mail')
    JIRA('Notify about new releases via JIRA')

    attr_reader :description

    def init(description)
      @description = description
    end
  end
end
