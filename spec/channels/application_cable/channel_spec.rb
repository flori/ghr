require 'rails_helper'

describe ApplicationCable::Channel do
  it "exists and is a subclass of ActionCable::Channel::Base" do
    expect(ApplicationCable::Channel).to be < ActionCable::Channel::Base
  end
end
