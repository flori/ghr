# GHR - GitHub Releases

GHR is an application that imports information about GitHub tags or releases of
a repository into a database as soon as they are published. This information
can then be consumed via JSON, Atom feeds or automatically create a JIRA issue
to eventually update to the new release if appropriate or necessary.

## Features

- **Multi-notification Support**: Automatically notify via email or JIRA when
  new releases are detected
- **Flexible Filtering**: Configure tag patterns and version requirements to
  filter relevant releases
- **Dual Import Modes**: Monitor full GitHub releases or lightweight tags
- **Rich API Endpoints**: JSON and Atom feed support for easy integration
- **Background Processing**: Efficiently handles release imports in the
  background
- **Health Checks**: Built-in readiness and liveness endpoints

## Configuration

### Required Environment Variables

These variables must be configured for the application to function:

- `GHR_GITHUB_PERSONAL_ACCESS_TOKEN` - A GitHub API token with `public_repo` scope
- `SECRET_KEY_BASE` - The Rails' `SECRET_KEY_BASE` random string used for cryptographic security
- `DATABASE_URL` - Your database URL, e.g. `postgresql://user:password@dbhost:5432/ghr_production`

### Optional Environment Variables with Defaults

These variables have sensible defaults and only need to be configured if you want different behavior:

#### Application Settings

- `GHR_HOST` - The hostname the GHR app can be reached under (required in
  production)
- `GHR_HOSTS_ALLOWED` = "" - Comma-separated list of allowed hostnames for
  Rails
- `SCHEDULE_EVERY` = "1h" - How often to check for new releases
- `PORT` = 3000 - Port number the GHR-App can be reached under
- `RAILS_LOG_LEVEL` = "info" - Rails log level
- `RAILS_MAX_THREADS` = 3 - Maximum number of Rails threads
- `RUBY_YJIT_ENABLE` = 1 (non-test) or 0 (test) - Ruby YJIT enable flag

#### JIRA Integration

- `JIRA_ENABLED` = "0" - Set to "1" to enable JIRA notifications
- `JIRA_USERNAME` - The JIRA username/email for generated issues
- `JIRA_URL` - The JIRA base URL, e.g. https://foo.atlassian.net:443/
- `JIRA_PROJECT` - The JIRA project prefix for the issues
- `JIRA_API_TOKEN` - The JIRA API token to create issues with
- `JIRA_COMPONENT` - The JIRA component identifier (optional)
- `JIRA_LABELS` = "release" - Comma-separated labels to assign to issues

#### Email Notifications

- `EMAIL_ENABLED` = "0" - Set to "1" to enable email notifications
- `EMAIL_NOTIFY_USER` - The user to notify via email for new releases
- `EMAIL_NOTIFY_SMTP_URL` - SMTP URL for sending emails

### Production Required Variables

These variables are required in production environments:

- `REVISION` - Current software revision of GHR

Locally you can put them into a `.env` file for dotenv to read.

## Architecture Overview

The following diagram shows the core architecture of GHR:

```mermaid
graph LR
    A[Github API] --> B[GithubReleaseImporter]
    B --> C[Database: GithubRepo]
    C --> D[GithubRelease]
    D --> E[Notifier Plugins]
    E --> F[JIRA]
    E --> G[Email]
    E --> H[Other Notifiers]
```

This shows how GitHub releases flow through the system from API fetches to
database storage and finally to notification services.

### Import Process Flow

The import process follows this sequence:

```mermaid
sequenceDiagram
    participant S as Scheduler
    participant I as AllNewGithubReleasesImporter
    participant R as GithubReleaseImporter
    participant G as GithubClient
    participant D as Database
    participant E as Notifier plugins

    S->>I: Trigger import
    I->>R: Process each repo
    R->>G: Fetch releases/tags
    G-->>R: Return releases
    R->>D: Save new releases
    R->>E: Notify via configured notifiers
```

This diagram illustrates how the background job system coordinates with GitHub
API calls and database operations.

### Configuration Flow

The configuration management works as follows:

```mermaid
graph LR
    A[Environment Variables] --> B[GhrConfig Module]
    B --> C[Validation & Defaults]
    C --> D[Application Services]
    D --> E[GithubClient]
    D --> F[JIRAClient]
    D --> G[NotificationMailer]
```

This shows how environment variables are processed through the configuration
system to reach various application services.

## Setup

Install docker, all commands are executed inside a docker container during
development, e.g. `run bash` to get a shell.

Then:

```bash
$ direnv allow
$ setup
$ open http://localhost:8123
```

If you deploy this in the cloud, make sure that only one instance is running,
otherwise the Rufus scheduler might get confused.

## Run specs

```bash
$ run rspec
```

It also generates a coverage report in the `coverage` subdirectory.

## Create YARD documentation

```bash
$ run yard
```

creates a `doc` subdirectory.

## Update bundled gems

First

```bash
$ update
```

then build again with

```bash
$ build
```

## Run rails console

```bash
$ run rails console
```

## Usage

In the rails console add a new repo, e.g. grafana via:

```ruby
GithubRepo.add(
  user:                'grafana',
  repo:                'grafana',
  tag_filter:          '\Av(\d+.\d+.\d+)\z',
  version_requirement: [">=12.1"],
  configured_notifiers: [:Email, :JIRA]
)
```

Then http://localhost:8123/repos will return a JSON document like this:

```json
[
  {
    "url": "https://ghr.gate.ping.de/repos/grafana:grafana",
    "atom_url": "https://ghr.gate.ping.de/repos/grafana:grafana.atom",
    "releases_count": 2,
    "user": "grafana",
    "repo": "grafana",
    "tag_filter": "\\Av(\\d+\\.\\d+\\.\\d+)\\z",
    "version_requirement": [
      ">=12.1"
    ],
    "lightweight": false,
    "import_enabled": true,
    "configured_notifiers": [
      "Email", "JIRA"
    ],
    "created_at": "2025-08-28T11:01:04.709Z",
    "updated_at": "2025-08-28T11:01:09.082Z"
  }
]
```

You can then subscribe to the `atom_url` above in your RSS reader to keep track
of the releases.

JIRA is optional, but if used, please see `config/jira.yml`. If you have the
JIRA integration configured, a JIRA issue will be generated for subsequent
releases, that satisfy the `tag_filter` and `version_requirement` criteria.

## Architecture

### Core Components

- **GithubRepo**: Represents a GitHub repository being monitored
- **GithubRelease**: Represents individual releases from GitHub
- **Notifier::Plugin**: Enumerated notification plugins (Email, JIRA)
- **Importers**: Handle GitHub API interactions and release creation
- **Notifiers**: Handle specific notification mechanisms

### Import Process

1. `AllNewGithubReleasesImporter` - Background job that schedules import checks
2. `GithubReleaseImporter` - Handles actual GitHub API calls and release creation
3. Notification via `GithubReleaseJIRANotifier` or `GithubReleaseEmailNotifier`

### Configuration Management

Uses `ConstConf` for type-safe configuration management with validation using
environment variables.

## Author

**GHR** was written by Florian Frank [Florian Frank](mailto:flori@ping.de)

## License

[MIT License](./LICENSE)
