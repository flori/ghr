describe AllNewGithubReleasesImporter, type: :model do
  let :github_repo do
    GithubRepo.create(
      user: 'metabase',
      repo: 'metabase',
      tag_filter: '\\Av(\\d+\\.\\d+\\.\\d+)\\z',
      configured_notifiers: %[ JIRA ],
    )
  end

  it 'can perform' do
    expect(GithubReleaseImporter).to receive(:new).
      with(github_repo: github_repo, notify: true).
      and_return(double(perform: 23))
    described_class.new.perform
  end

  it "won't import unless import_enabled" do
    github_repo.update(import_enabled: false)
    expect(GithubReleaseImporter).not_to receive(:new)
    described_class.new.perform
  end

  it 'can perform when there are no releases' do
    expect(GithubReleaseImporter).to receive(:new).
      with(github_repo: github_repo, notify: true).
      and_return(double(perform: nil))
    described_class.new.perform
  end

  context 'when an import fails' do
    let(:exception) { StandardError.new('Something went wrong!') }

    before do
      expect(GithubReleaseImporter).to receive(:new).and_raise(exception)
    end

    it 'always logs the error' do
      expect(Rails.logger).to receive(:error).
        with("Error StandardError \"Something went wrong!\" while importing releases for #{github_repo.to_param}.")
      expect(Rails.logger).to receive(:error).with(exception)
      described_class.new.perform
    end

    context 'when NotificationMailer is configured' do
      before do
        expect(NotificationMailer).to receive(:configured?).and_return(true)
      end

      it 'sends an error notification email' do
        expect(NotificationMailer).to receive(:with).
          with(github_repo: github_repo, exception: exception).
          and_return(double(error_email: double(deliver_now: true)))

        described_class.new.perform
      end
    end

    context 'when NotificationMailer is not configured' do
      before do
        expect(NotificationMailer).to receive(:configured?).and_return(false)
      end

      it 'does not send an error notification email' do
        github_repo # Triggers creation
        expect(NotificationMailer).not_to receive(:with)
        described_class.new.perform
      end
    end
  end

  context 'when the import fails transiently' do
    before do
      expect_any_instance_of(Kernel).to receive(:sleep).at_least(:once)
      allow(Rails.logger).to receive(:info)
    end

    it 'recovers after a few failed attempts' do
      # First 2 attempts fail, 3rd succeeds
      importer_double = double
      expect(importer_double).to receive(:perform).and_raise(JIRA::HTTPError.new('Transient error')).twice
      expect(importer_double).to receive(:perform).and_return(5)

      expect(GithubReleaseImporter).to receive(:new).exactly(3).times.and_return(importer_double)
      expect(Rails.logger).to receive(:warn).with(/Retrying import for #{github_repo.to_param}/).twice
      expect(Rails.logger).to receive(:info).with(/Imported 5 releases for #{github_repo.to_param}/)

      described_class.new.perform
    end
  end

  context 'when the import fails persistently' do
    let(:exception) { JIRA::HTTPError.new('Persistent error') }

    before do
      expect_any_instance_of(Kernel).to receive(:sleep).at_least(:once)
      allow(Rails.logger).to receive(:info)
      expect(NotificationMailer).to receive(:configured?).and_return(true)
    end

    it 'exhausts all retries and then sends an email' do
      # Fail 5 times (the limit of Tins::Attempt in the implementation)
      importer_double = double
      expect(importer_double).to receive(:perform).and_raise(exception).exactly(5).times

      expect(GithubReleaseImporter).to receive(:new).exactly(5).times.and_return(importer_double)
      expect(Rails.logger).to receive(:warn).with(/Retrying import for #{github_repo.to_param}/).exactly(4).times
      expect(NotificationMailer).to receive(:with).
        with(github_repo: github_repo, exception: an_instance_of(JIRA::HTTPError)).
        and_return(double(error_email: double(deliver_now: true)))

      described_class.new.perform
    end
  end
end
