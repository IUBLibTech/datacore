require 'rails_helper'

class HomepageControllerBehaviorMockParent

  def index
  end
end

class HomepageControllerBehaviorMock < HomepageControllerBehaviorMockParent
  include ::Extensions::HyraxExtensions::HomepageController::HomepageControllerBehavior

end



describe Extensions::HyraxExtensions::HomepageController::HomepageControllerBehavior do

  subject { HomepageControllerBehaviorMock.new }

  describe "#index" do
    before {
      allow(FeaturedCollectionList).to receive(:new).and_return "new FeaturedCollectionList"
    }

    it "sets instance variable" do
      expect(FeaturedCollectionList).to receive(:new)
      subject.index

      expect(subject.instance_variable_get(:@featured_collection_list)).to eq "new FeaturedCollectionList"
    end

    skip "Add test for super"
  end
end
