require 'rails_helper'

class MockConfig

  def initialize(text)
    @value = text
  end
  def value
    @value
  end

  def value=(text)
    @value = text
  end
end

class MockContentBlock

  def permit(param)
  end
end




RSpec.describe RackAttacksController, type: :controller do

  describe "#show" do
    before {
      subject.instance_variable_set(:@rack_attack_config, MockConfig.new("rack attack config"))
      allow(subject).to receive(:render).with(body: "rack attack config")
    }

    it "renders @rack_attack_config as body" do
      expect(subject).to receive(:render).with(body: "rack attack config")

      subject.show
    end
  end


  describe "#edit" do
    before {
      subject.instance_variable_set(:@rack_attack_config, "rack attack config")
      allow(subject).to receive(:authorize!).with(:edit, "rack attack config")
    }

    it "calls authorize!" do
      expect(subject).to receive(:authorize!).with(:edit, "rack attack config")

      subject.edit
    end
  end


  pending "#update"


  # private methods

  describe "#load_rack_attack_config" do
    before {
      allow(Datacore::RackAttackConfig).to receive(:config_source).and_return "config source"  
    }
    it "sets the @rack_attack_config variable" do
      subject.send(:load_rack_attack_config)
      
      expect(subject.instance_variable_get(:@rack_attack_config)).to eq "config source"
    end
  end


  describe "#throw_breadcrumbs" do
    before {
      allow(subject).to receive(:root_path).and_return "root path"
      allow(subject.hyrax).to receive(:dashboard_path).and_return "dashboard path"
      allow(subject).to receive(:edit_rack_attack_path).and_return "edit rack"

      # Unable to stub hyrax YAML values
      allow(subject).to receive(:add_breadcrumb).with("Home", "root path")
      allow(subject).to receive(:add_breadcrumb).with("Dashboard", "dashboard path")
      allow(subject).to receive(:add_breadcrumb).with("Configuration", "#")
      allow(subject).to receive(:add_breadcrumb).with("Rack Attack", "edit rack")
    }

    it "adds breadcrumbs" do
      expect(subject).to receive(:root_path)
      expect(subject.hyrax).to receive(:dashboard_path)
      expect(subject).to receive(:edit_rack_attack_path)

      expect(subject).to receive(:add_breadcrumb).with("Home", "root path")
      expect(subject).to receive(:add_breadcrumb).with("Dashboard", "dashboard path")
      expect(subject).to receive(:add_breadcrumb).with("Configuration", "#")
      expect(subject).to receive(:add_breadcrumb).with("Rack Attack", "edit rack")

      subject.send(:throw_breadcrumbs)
    end
  end


  describe "#permitted_params" do
    mock_block = MockContentBlock.new
    before {
      allow(subject.params).to receive(:require).with(:content_block).and_return mock_block
    }
    it "sets params to require content block" do
      expect(subject.params).to receive(:require).with(:content_block)
      expect(mock_block).to receive(:permit).with(:value)

      subject.send(:permitted_params)
    end
  end

end
