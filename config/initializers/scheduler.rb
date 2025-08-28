require 'rufus-scheduler'

return if defined?(Rails::Console) || Rails.env.test? || File.split($PROGRAM_NAME).last == 'rake'

s = Rufus::Scheduler.singleton

s.every GhrConfig::SCHEDULE_EVERY do
  AllNewGithubReleasesImporter.new.perform
end
