require 'rails_helper'

class MenuPresenterBehaviorMockParent

  def controller_name
  end
end

class MenuPresenterBehaviorMock < MenuPresenterBehaviorMockParent
  include ::Extensions::Hyrax::MenuPresenter::MenuPresenterBehavior

end



describe Extensions::Hyrax::MenuPresenter::MenuPresenterBehavior do

  subject { MenuPresenterBehaviorMock.new }

  describe "#settings_section?" do

    controller_names = %w[appearances collection_types pages content_blocks features rack_attacks robots]
    controller_names.each do |controller_name|

       context "when controller name #{controller_name} is in the settings section" do
         before {
           allow(subject).to receive(:controller_name).and_return controller_name
         }

         it "returns true" do
           expect(subject.settings_section?).to eq true
         end
      end
    end

    context "when controller name is NOT in the settings section" do
      before {
        allow(subject).to receive(:controller_name).and_return "homepage"
      }

      it "returns false" do
        expect(subject.settings_section?).to eq false
      end
    end

  end
end
