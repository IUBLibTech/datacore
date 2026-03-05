require 'rails_helper'

class MockApp
  def call(env)
  end
end



RSpec.describe RackMultipartBufSizeSetter do

  let(:rack_app) { MockApp.new }
  subject { described_class.new(rack_app) }

  describe "#initialize" do
    it "sets @app variable" do
      rack = RackMultipartBufSizeSetter.new(rack_app)

      expect(rack.instance_variable_get(:@app)).to eq rack_app
    end
  end


  describe "#call" do
    envtest = {}
    it "merges key and value into env hash and @app calls env" do
      expect(rack_app).to receive(:call).with(Rack::RACK_MULTIPART_BUFFER_SIZE => 1024 * 1024)

      subject.call(envtest)
      expect(envtest).to eq Rack::RACK_MULTIPART_BUFFER_SIZE => 1024 * 1024
    end
  end
end
