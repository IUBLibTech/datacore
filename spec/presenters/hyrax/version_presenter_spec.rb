require 'rails_helper'

class VersionMock

  def initialize(created_at = Time.now)
    @created = created_at
  end

  def created
    @created if @created
  end
end

RSpec.describe Hyrax::VersionPresenter do

  let(:version) { VersionMock.new(DateTime.new(2020, 2, 20) )}

  subject{ described_class.new(version) }

  it { is_expected.to delegate_method(:label).to(:version) }
  it { is_expected.to delegate_method(:uri).to(:version) }

  describe "#current!" do

    it "#current_user?" do
      expect(subject.current!).to eq true
    end

  end

  describe "#created" do

    it "returns version created with time zone formatted to string" do
      expect(subject.created).to eq "February 20th, 2020 00:00"
    end

  end

end