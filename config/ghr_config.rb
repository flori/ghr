module GhrConfig
  include ConstConf

  description 'Root configuration module'
  prefix      'GHR'

  REVISION = set do
    description 'Current software revision of GHR'
    prefix      ''
    required { Rails.env.production? }
    check    { value.blank? || value.to_s =~ /\A\h{7}\z/ }
  end

  SIMPLE_HOST_REGEX = /\A[a-z\-]+\.[a-z\-\.]+\z/

  HOST = set do
    description 'HOST name the GHR-App can be reached under'
    required { Rails.env.production? }
    check    { value.blank? || value =~ SIMPLE_HOST_REGEX && value.size <= 253 }
  end

  HOSTS_ALLOWED = set do
    description 'Connections under these hostnames are allowed in Rails.'
    default ''
    decode { it.split(?,).map(&:strip) }
    check  { value.all? { |host| host == 'localhost' || host =~ SIMPLE_HOST_REGEX && host.size <= 253 } }
  end

  SCHEDULE_EVERY = set do
    description 'Schedule imports of ne GitHub releases every so often'
    default '1h'
  end

  GITHUB_PERSONAL_ACCESS_TOKEN = set do
    description 'GitHub Personal Access Token for repo access'
    required true
    sensitive true
    check { value.to_s =~ /\Aghp_[A-Za-z0-9]{36}\z/ }
  end

  module SERVICE
    description 'Service settings'
    prefix      ''

    REDIS_URL = set do
      description 'Redis server URL'
      default 'redis://localhost:6379/1'
      sensitive true
      check { URI.parse(value).scheme == 'redis' rescue false }
    end

    DATABASE_URL = set do
      description 'Database server URL'
      sensitive true
      required  { Rails.env.production? }
      check { value.blank? || URI.parse(value).scheme == 'postgresql' rescue false }
    end
  end

  module EMAIL
    description 'E-Mail Notifier plugin settings'
    prefix      'EMAIL'

    ENABLED = set do
      description 'EMAIL plugin is enabled if set to "1", disabled if set to "0"'
      activated :itself
      decode    -> value { value == "1" }
      default   { '0' }
      required true
    end

    NOTIFY_USER = set do
      description 'User to notify via E-Mail for new GitHub releases'
      required { EMAIL::ENABLED? }
    end

    NOTIFY_SMTP_URL = set do
      description 'SMTP URL via which E-Mails should be sent'
      decode   { URI(it) if it.present? }
      required { EMAIL::ENABLED? }
      sensitive true
      check { value.blank? || URI.parse(value).scheme == 'smtp' rescue false }
    end
  end

  module JIRA
    description 'JIRA Notifier plugin settings'
    prefix      'JIRA'

    ENABLED = set do
      description 'JIRA plugin is enabled if set to "1", disabled if set to "0"'
      activated :itself
      decode    -> value { value == "1" }
      default   { '0' }
      required  true
    end

    USERNAME = set do
      description 'JIRA username'
      required { JIRA::ENABLED? }
    end

    URL = set do
      description 'JIRA organisation URL'
      required { JIRA::ENABLED? }
    end

    PROJECT = set do
      description 'JIRA Project name'
      required { JIRA::ENABLED? }
    end

    COMPONENT = set do
      description 'JIRA COMPONENT identifer for issue'
      required { JIRA::ENABLED? }
    end

    LABELS = set do
      description 'Labels to assign to issues.'
      default 'release'
      decode   { it.split(?,) }
      required { JIRA::ENABLED? }
    end

    API_TOKEN = set do
      description 'JIRA API Token'
      sensitive true
      required { JIRA::ENABLED? }
    end
  end

  module RUBY
    description 'Ruby specificy configuration settings'
    prefix      'RUBY'

    YJIT_ENABLE = set do
      description 'Ruby YJIT is enabled with "1" (the default for everthing but tests)'
      activated { it.to_i == 1 }
      default   { Rails.env.test? ? 0 : 1 }
    end
  end

  module PUMA
    description 'Puma specific configuration settings'
    prefix      ''

    PIDFILE = set do
      description 'Server PID file for Puma'
    end

    SOLID_QUEUE_IN_PUMA = set do
      description 'Run the Solid Queue supervisor inside of Puma for single-server deployments'
    end

    PORT = set do
      description 'PORT number the GHR-App can be reached under'
      default 3000
      decode(&:to_i)
      check { (1..(1 << 16) - 1) === value }
    end

    WEB_CONCURRENCY = set do
      description 'Number of Puma workers activated'
      decode -> n { Integer(n) if n.present? }
    end
  end

  module RAILS
    description 'Rails specific configuration settings'
    prefix      'RAILS'

    LOG_LEVEL = set do
      description 'Rails log level'
      default 'info'
    end

    MAX_THREADS = set do
      description 'Maximum number fo Rails threads'
      default 3
      decode(&:to_i)
    end

    CI = set do
      description 'We are running on CI if "true" or "1"'
      prefix      ''
      decode { /\Atrue|1\z/i.match?(it) }
    end
  end
end
