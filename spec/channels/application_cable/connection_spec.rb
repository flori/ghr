require 'rails_helper'

describe ApplicationCable::Connection do
  it "exists and is a subclass of ActionCable::Connection::Base" do
    expect(ApplicationCable::Connection).to be < ActionCable::Connection::Base
  end
end
