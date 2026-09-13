require 'rails_helper'

class EscapeMock
  include ::Extensions::Hydra::AccessControls::Permission::EscapingObsoletions

end

describe Extensions::Hydra::AccessControls::Permission::EscapingObsoletions do

  subject { EscapeMock.new }

  pending "#agent_name"

  describe "#build_agent_resource" do
    before {
      allow(::CGI).to receive(:escape).with("name").and_return " de plume"
      allow(::RDF::URI).to receive(:new).with("nom# de plume").and_return "alias"
      allow(::Hydra::AccessControls::Agent).to receive(:new).with("alias")
    }
    it "calls Agent.new" do
      expect(::Hydra::AccessControls::Agent).to receive(:new).with("alias")
      subject.build_agent_resource "nom", "name"
    end
  end

end
