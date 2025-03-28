require 'rails_helper'

class QueryingFileSet
  include ::Hyrax::FileSet::Querying::ClassMethods
end


RSpec.describe Hyrax::FileSet::Querying::ClassMethods  do
  subject { QueryingFileSet.new }

  describe '#urnify' do
    it "returns urnification of string" do
      expect( subject.urnify "Spectacular").to eq("urn:sha1:Spectacular")
    end

  end

end
