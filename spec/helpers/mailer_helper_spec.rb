require 'rails_helper'

RSpec.describe MailerHelper, type: :helper do
  it "can format markdown" do
    expect(helper.markdown("**strong**")).to eq("<p><strong>strong</strong></p>\n")
  end
end
