require 'rails_helper'

RSpec.describe Hyrax::SelectCollectionTypePresenter do
  subject { described_class.new(double) }

  describe "delegates methods to collection_type:" do
    [:title, :description, :admin_set?, :id].each do
    |method|
      it "#{method}" do
        expect(subject).to delegate_method(method).to(:collection_type)
      end
    end
  end

end
