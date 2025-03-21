require 'rails_helper'

RSpec.describe Collection do

  describe '#metadata_report_title_pre' do
     it 'returns true' do
       expect(subject.metadata_report_title_pre).to eq('Collection: ')
     end
  end

end
