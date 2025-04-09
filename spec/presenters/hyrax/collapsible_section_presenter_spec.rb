require 'rails_helper'

RSpec.describe Hyrax::CollapsableSectionPresenter do
  let(:view_context) { "View Context" }
  let(:text) { "Text" }
  let(:id) { 999 }
  let(:icon_class) { "Iconic" }

  subject{ described_class.new(view_context: view_context, text: text, id: id, icon_class: icon_class, open: true) }


  describe "delegates methods to collection_type" do
    it { is_expected.to delegate_method(:content_tag).to(:view_context) }
    it { is_expected.to delegate_method(:safe_join).to(:view_context) }
  end

  it { is_expected.to delegate_method(:content_tag).to(:view_context) }
  it { is_expected.to delegate_method(:safe_join).to(:view_context) }


  pending "#render"
end
