require 'rufus-scheduler'

return if defined?(Rails::Console) || Rails.env.test? || File.split($PROGRAM_NAME).last == 'rake'

s = Rufus::Scheduler.singleton

s.every ENV.fetch('GHR_SCHEDULE_EVERY', '1h') do
  AllNewGithubReleasesImporter.new.perform
end
