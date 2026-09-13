require 'rails_helper'

RSpec.describe Hyrax::UploadedFile do

  describe "table.name" do
    it do
      expect(Hyrax::UploadedFile.table_name).to eq "uploaded_files"
    end
  end


end