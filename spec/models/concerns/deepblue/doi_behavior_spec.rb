class DoiMock
  include ::Deepblue::DoiBehavior

  def initialize
    @doi = "doi_pending"
  end

  def doi
    @doi
  end

  def doi=(value)
    @doi = value
  end

  def id
    1001
  end

  def file_sets
    []
  end

  def save
  end

  def reload
  end
end

class UserMock

  def email
    "current_user@example.com"
  end

  def to_s
      "current_user"
  end
end

RSpec.describe Deepblue::DoiBehavior do

  let( :mock ) { DoiMock.new }

  describe 'constants' do
    it do
      expect( Deepblue::DoiBehavior::DOI_MINTING_ENABLED ).to eq true
      expect( Deepblue::DoiBehavior::DOI_PENDING ).to eq "doi_pending"
      expect( Deepblue::DoiBehavior::DOI_MINIMUM_FILE_COUNT ).to eq 1
    end
  end

  describe "#doi_minted?" do
    context "when doi is nil" do
      before {
        allow(mock).to receive(:doi).and_return nil
      }
      it "returns false" do
        expect(mock.doi_minted?).to eq false
      end
    end

    context "when doi is not nil" do
      it "returns true" do
        expect(mock.doi_minted?).to eq true
      end
    end

    context "when !doi.nil? raises an error" do
      before {
        allow(mock).to receive(:doi).and_raise "Error"
      }
      it "returns nil" do
        expect(mock.doi_minted?).to be_blank
      end
    end
  end

  describe "#doi_minting_enabled?" do
    it "returns true" do
      expect(mock.doi_minting_enabled?).to eq true
    end
  end


  describe "#doi_pending?" do
    context "doi returns 'doi_pending'" do
      it "returns true" do
        expect(mock.doi_pending?).to eq true
      end
    end

    context "doi does not return 'doi_pending'" do
      before {
        allow(mock).to receive(:doi).and_return "doi"
      }
      it "returns false" do
        expect(mock.doi_pending?).to eq false
      end
    end
  end


  describe "#doi_mint" do
    before {
      allow(Deepblue::LoggingHelper).to receive(:here).and_return "here"
      allow(Deepblue::LoggingHelper).to receive(:called_from).and_return "called from"
    }

    context "when doi is 'doi_pending'" do
      before {
        allow(Deepblue::LoggingHelper).to receive(:bold_debug).with(["here", "called from", "work.id=1001", "doi=doi_pending", "current_user=user",
                                                                    "event_note=event note", "enforce_minimum_file_count=true", "job_delay=0"])
      }
      it "returns false" do
        expect(Deepblue::LoggingHelper).to receive(:bold_debug).with(["here", "called from", "work.id=1001", "doi=doi_pending", "current_user=user",
                                                                     "event_note=event note", "enforce_minimum_file_count=true", "job_delay=0"])
        expect(mock.doi_mint(current_user: "user", event_note: "event note")).to eq false
      end
    end

    context "when doi_minted? returns true" do
      before {
        allow(mock).to receive(:doi).and_return "doi"
        allow(Deepblue::LoggingHelper).to receive(:bold_debug).with(["here", "called from", "work.id=1001", "doi=doi", "current_user=user",
                                                                     "event_note=event note", "enforce_minimum_file_count=true", "job_delay=0"])
        allow(mock).to receive(:doi_minted?).and_return true
      }
      it "returns false" do
        expect(Deepblue::LoggingHelper).to receive(:bold_debug).with(["here", "called from", "work.id=1001", "doi=doi", "current_user=user",
                                                                     "event_note=event note", "enforce_minimum_file_count=true", "job_delay=0"])
        expect(mock.doi_mint(current_user: "user", event_note: "event note")).to eq false
      end
    end

    context "when enforce_minimum_file_count param is true && zero file_sets" do
      before {
        allow(mock).to receive(:doi).and_return "doi"
        allow(Deepblue::LoggingHelper).to receive(:bold_debug).with(["here", "called from", "work.id=1001", "doi=doi", "current_user=user",
                                                                     "event_note=event note", "enforce_minimum_file_count=true", "job_delay=0"])
        allow(mock).to receive(:doi_minted?).and_return false
      }

      it "returns false" do
        expect(Deepblue::LoggingHelper).to receive(:bold_debug).with(["here", "called from", "work.id=1001", "doi=doi", "current_user=user",
                                                                      "event_note=event note", "enforce_minimum_file_count=true", "job_delay=0"])
        expect(mock.doi_mint(current_user: "user", event_note: "event note")).to eq false
      end
    end

    context "when file_sets exist" do
      user = UserMock.new

      before {
        allow(mock).to receive(:doi).and_return "doi"
        allow(Deepblue::LoggingHelper).to receive(:bold_debug).with(["here", "called from", "work.id=1001", "doi=doi", "current_user=current_user",
                                                                     "event_note=event note", "enforce_minimum_file_count=true", "job_delay=0"])
        allow(mock).to receive(:doi_minted?).and_return false
        allow(mock).to receive(:file_sets).and_return ["file_set1"]
        allow(Deepblue::LoggingHelper).to receive(:bold_debug).with(["here", "called from", "work.id=1001", "doi=doi_pending", "about to call DoiMintingJob"])
        allow(::DoiMintingJob).to receive(:perform_later).with(1001, current_user: "current_user@example.com", job_delay: 0)
      }
      it "returns true" do
        expect(Deepblue::LoggingHelper).to receive(:bold_debug).with(["here", "called from", "work.id=1001", "doi=doi", "current_user=current_user",
                                                                     "event_note=event note", "enforce_minimum_file_count=true", "job_delay=0"])
        expect(mock).to receive(:save)
        expect(mock).to receive(:reload)

        expect(mock.doi_mint(current_user: user, event_note: "event note")).to eq true

        subject.instance_variable_get(:@doi) == "doi_pending"
      end

      it "verify doi_mint calls bold_debug a second time and perform_later once" do
        skip "Add a test"
      end
    end


    context "when Exception occurs" do
      user = UserMock.new

      before {
        exception = StandardError.new("Doi Mint Error")
        exception.set_backtrace("backtrace")
        allow(mock).to receive(:doi).and_raise exception
      }
      it "calls Rails.logger.error and returns nil" do
        expect(Rails.logger).to receive(:error).with("DoiBehavior.doi_mint for curation_concern.id 1001 -- StandardError: Doi Mint Error at backtrace")
        expect(mock.doi_mint(current_user: user, event_note: "event note")).to be_blank
      end
    end

  end

end
