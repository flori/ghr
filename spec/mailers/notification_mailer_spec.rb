require "rails_helper"

describe NotificationMailer, type: :mailer do
  describe "github_release_email" do
    let :notifier do
      double(
        summary: 'The Summary',
        description: '**The Description**',
      )
    end

    let :mail do
      NotificationMailer.with(notifier:).github_release_email
    end

    let :mail_to do
      'test@example.com'
    end

    before do
      expect_any_instance_of(NotificationMailer).to receive(:notify_user).
        and_return(mail_to)
    end

    it "renders the headers" do
      expect(mail.subject).to eq("The Summary")
      expect(mail.to).to eq([mail_to])
      expect(mail.from).to eq(["noreply@example.com"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to include("<p><strong>The Description</strong></p>")
    end
  end
end
