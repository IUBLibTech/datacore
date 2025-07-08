require 'rails_helper'

class SearchMock
  include ::Extensions::Qa::Authorities::Collections::CollectionsSearch

end



describe Extensions::Qa::Authorities::Collections::CollectionsSearch do

  subject { SearchMock.new }

  describe "#search" do
    context "when controller.current_user has no value" do
      it "returns empty array" do
        expect(subject.search "q", OpenStruct.new(current_user: nil)).to be_empty
      end
    end

    context "when controller.current_user has a value" do

      it "returns mapped documents" do
        skip "Add a test"
      end
    end
  end
end