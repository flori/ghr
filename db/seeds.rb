# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)
begin
  github_repo = GithubRepo.add(
    user: 'rails',
    repo: 'rails',
    tag_filter: '\Av(\d+\.\d+\.\d+)\z',
    version_requirement: %w[ >7 ],
    configured_notifiers: %i[ JIRA ]
  )
  GithubReleaseImporter.new(github_repo:, notify: false).perform
rescue ActiveRecord::RecordInvalid => e
  puts "Caught #{e.class}: #{e}"
end
