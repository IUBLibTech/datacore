require 'rails_helper'

class PresentsAttributesMock
  include ::Hyrax::PresentsAttributes

end


RSpec.describe Hyrax::PresentsAttributes do
  subject{ PresentsAttributesMock.new() }

  pending "#attribute_to_html"
  pending "#permission_badge"

  describe "#permission_badge_class" do
    it "returns PermissionBadge" do
      expect(subject.permission_badge_class).to eq Hyrax::PermissionBadge
    end
  end


  pending "#display_microdata?"
  pending "#microdata_type_to_html"

end
