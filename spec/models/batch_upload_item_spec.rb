require 'rails_helper'


RSpec.describe BatchUploadItem do

  pending '#in_collection_ids'

  describe '#create_or_update' do
    it "raises error" do
      expect { subject.create_or_update }.to raise_error("This is a read only record")
    end
  end

end
