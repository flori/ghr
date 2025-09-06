require 'rails_helper'

describe ApplicationJob do
  it "exists and is a subclass of ActiveJob::Base" do
    expect(ApplicationJob).to be < ActiveJob::Base
  end

  it "can be instantiated" do
    expect { described_class.new }.not_to raise_error
  end
end
