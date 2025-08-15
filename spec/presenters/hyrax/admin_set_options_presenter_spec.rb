require 'rails_helper'

class MockService
  def initialize(mockadminset)
    @mockadminset = mockadminset
  end

  def search_results(access)
    @mockadminset
  end
end

class MockAdminSet
  def initialize(id, title)
    @id = id
    @title = title
  end

  def id
    @id
  end

  def to_s
    @title
  end
end

class MockWorkflow
  def allows_access_grant?
  end
end

class MockPermissionTemplate
  def initialize(release_no_delay, release_date, release_before_date, visibility)
    @release_no_delay = release_no_delay
    @release_date = release_date
    @release_before_date = release_before_date
    @visibility = visibility
  end

  def release_no_delay?
    @release_no_delay
  end

  def release_before_date?
    @release_before_date
  end

  def release_date
    @release_date
  end

  def visibility
    @visibility
  end
end


RSpec.describe Hyrax::AdminSetOptionsPresenter do

  subject { described_class.new( "service" ) }


  describe '#initialize' do
    it "sets instance variable" do
      admin_set_options = Hyrax::AdminSetOptionsPresenter.new("service")

      admin_set_options.instance_variable_get(:@service) == "service"
    end
  end


  describe "#select_options" do
    admin_set_mock = MockAdminSet.new(101, "monogram")

    before {
      subject.instance_variable_set(:@service, MockService.new([admin_set_mock]))
      allow(subject).to receive(:data_attributes).with( admin_set_mock ).and_return "data attributes"
    }
    it "returns admin set(s)" do
      expect(subject).to receive(:data_attributes).with( admin_set_mock )
      expect(subject.select_options).to eq [["monogram", 101, "data attributes"]]
    end
  end


  describe "#select_options_default_admin" do
    mock_admin_set1 = MockAdminSet.new("admin_set/default", "Default Admin Set")
    mock_admin_set2 = MockAdminSet.new("brand_new_set", "Personal Admin Set")

    before {
      subject.instance_variable_set(:@service, MockService.new([mock_admin_set1, mock_admin_set2]))
      allow(subject).to receive(:data_attributes).with( mock_admin_set1 ).and_return "data attributes"
    }
    it "returns default admin set" do
      expect(subject).to receive(:data_attributes).with( mock_admin_set1 )
      expect(subject).not_to receive(:data_attributes).with( mock_admin_set2 )

      expect(subject.select_options_default_admin).to eq [["Default Admin Set", "admin_set/default", "data attributes"]]
    end
  end


  describe "#select_options_non_default_admin" do
    mock_admin_set1 = MockAdminSet.new("admin_set/default", "Default Admin Set")
    mock_admin_set2 = MockAdminSet.new("brand_new_set", "Personal Admin Set")

    before {
      subject.instance_variable_set(:@service, MockService.new([mock_admin_set1, mock_admin_set2]))
      allow(subject).to receive(:data_attributes).with( mock_admin_set2 ).and_return "data attributes"
    }
    it "returns set(s) that are not the default admin set" do
      expect(subject).not_to receive(:data_attributes).with( mock_admin_set1 )
      expect(subject).to receive(:data_attributes).with( mock_admin_set2 )

      expect(subject.select_options_non_default_admin).to eq [["Personal Admin Set", "brand_new_set", "data attributes"]]
    end
  end


  # private methods

  describe "#data_attributes" do

    context "when find_by evaluates to true" do
      before {
        allow(Hyrax::PermissionTemplate).to receive(:find_by).with(source_id: "S-111").and_return true
        allow(subject).to receive(:attributes_for).with(permission_template: true)
      }
      it "calls attributes_for" do
        expect(subject).to receive(:attributes_for).with(permission_template: true)

        subject.send(:data_attributes, OpenStruct.new(id: "S-111"))
      end
    end

    context "when find_by evaluates to false" do
      before {
        allow(Hyrax::PermissionTemplate).to receive(:find_by).with(source_id: "S-111").and_return false
      }
      it "returns empty" do
        expect(subject).not_to receive(:attributes_for)

        expect(subject.send(:data_attributes, OpenStruct.new(id: "S-111"))).to be_empty
      end
    end
  end


  describe "#attributes_for" do
    context "when release_no_delay? is true and release_date and visibility are present" do
      permission_template = MockPermissionTemplate.new(true, nil, true, "visible")
      before {
        allow(subject).to receive(:sharing?).with(permission_template: permission_template).and_return "data sharing"
      }

      it "returns data-sharing, data-release-no-delay, data-release-before-date, and data-visibility" do
        expect(subject).to receive(:sharing?).with(permission_template: permission_template)

        expect(subject.send(:attributes_for, permission_template: permission_template)).to eq "data-sharing" => "data sharing",
          "data-release-no-delay" => true, "data-release-before-date" => true, "data-visibility" => "visible"
      end
    end

    context "when release_date present, no release_before_date? and no visibility" do
      permission_template = MockPermissionTemplate.new(false, "release date",false, nil)
      before {
        allow(subject).to receive(:sharing?).with(permission_template: permission_template).and_return "data sharing"
      }

      it "returns data-sharing and data-release-date" do
        expect(subject).to receive(:sharing?).with(permission_template: permission_template)

        expect(subject.send(:attributes_for, permission_template: permission_template)).to eq "data-sharing" => "data sharing",
          "data-release-date" => "release date"
      end
    end
  end


  describe "#sharing?" do
    context "when no workflow with permission template" do
      before {
        allow(subject).to receive(:workflow).with(permission_template: "permission template").and_return false
      }
      it "returns false" do
        expect(subject).to receive(:workflow).with(permission_template: "permission template")
        expect(subject.send(:sharing?, permission_template: "permission template")).to eq false
      end
    end

    context "when existing workflow with permission template" do
      workflow = MockWorkflow.new
      before {
        allow(subject).to receive(:workflow).with(permission_template: "permission template").and_return workflow
        allow(workflow).to receive(:allows_access_grant?).and_return true
      }
      it "calls allows_access_grant?" do
        expect(subject).to receive(:workflow).with(permission_template: "permission template")
        expect(workflow).to receive(:allows_access_grant?)
        expect(subject.send(:sharing?, permission_template: "permission template")).to eq true
      end
    end
  end


  describe "#workflow" do
    context "when not active_workflow" do
      it "returns blank" do
        expect(subject.send(:workflow, permission_template: OpenStruct.new(active_workflow: nil))).to be_blank
      end
    end

    context "when active_workflow" do
      before {
        allow(Sipity::Workflow).to receive(:find_by!).with(id: "C-333")
      }
      it "calls Sipity::Workflow.find_by! with active workflow id" do
        expect(Sipity::Workflow).to receive(:find_by!).with(id: "C-333")
        subject.send(:workflow, permission_template: OpenStruct.new(active_workflow: OpenStruct.new(id: "C-333")))
      end
    end
  end

end
