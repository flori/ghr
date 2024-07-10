# GHR - GitHub Releases

GHR is an application that imports information about Github tags or releases of
a repository into a database as soon as they are published. This information
can the be consumed via JSON, Atom feeds or automatically create a JIRA issue
to eventally update to the new release if appropriate or necessary.

## Configuration

You can define the following environment variables:

  - `DATABASE_URL`, your database, e. g. `postgresql://user:password@dbhost:5432/ghr_production`
  - `GHR_GITHUB_PERSONAL_ACCESS_TOKEN`, a github API token with `public_repo` scope
  - `JIRA_USERNAME`, the JIRA username/email for generated issues
  - `JIRA_URL`, the JIRA base url, e. g. https://foo.atlassian.net:443/
  - `JIRA_PROJECT`, the JIRA project prefix for the issues
  - `JIRA_API_TOKEN`, the JIRA API token to create issues with   
  - `SECRET_KEY_BASE`, the rails' `SECRET_KEY_BASE` random string used for cryptographic security

Locally you can put them into a `.env` file for dotenv to read.

## Setup

Install docker, all commands are executed inside a docker container during
development, e. g. `run bash` to get a shell.

Then:

```
$ direnv allow

$ setup

$ open http://localhost:8123
```

If you deploy this in the cloud, make sure that only one instance is running,
otherwise the rufus scheduler might get confused.

## Run specs

```
$ run rspec
```

It also generates a coverage report in the `coverage` subdirectory.

## Create YARD documentation

```
$ run yard
```

creates a `doc` subdirectory.

## Update bundled gems

First

```
$ update
```

then build again with

```
$ build
```

## Run rails console

```
$ run rails console
```

## Usage

In the rails console add a new repo, e.g. grafana via:

```ruby
GithubRepo.add(
  user:                'grafana',
  repo:                'grafana',
  tag_filter:          '\Av(\d+.\d+.\d+)\z',
  version_requirement: [">=10.4"]
)
```

Then http://localhost:8123/repos will return a JSON document like this:

```json
[
  {
    "url": "http://localhost:8123/repos/grafana:grafana",
    "atom_url": "http://localhost:8123/repos/grafana:grafana.atom",
    "releases_count": 9,
    "user": "grafana",
    "repo": "grafana",
    "tag_filter": "\\Av(\\d+.\\d+.\\d+)\\z",
    "version_requirement": [
      ">=10.4"
    ],
    "lightweight": false,
    "import_enabled": true,
    "created_at": "2024-07-11T00:24:40.555Z",
    "updated_at": "2024-07-11T00:24:44.731Z"
  }
]
```

You can then subscribe to the `atom_url` above in your RSS reader to keep track
of the releases.

JIRA is optional, but if used, please see `config/jira.yml`. If you have the
JIRA integration configured, a JIRA issue will be generated for subsequent
releases, that satisfy the `tag_filter` and `version_requirement` criteria.

## Author

Florian Frank <flori@ping.de>

## License

MIT, see LICENSE file.
