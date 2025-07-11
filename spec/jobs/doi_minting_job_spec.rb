# frozen_string_literal: true

describe DoiMintingJob do
  let(:current_user) { 'user@example.com' }
  let(:service) { Datacore::DoiMintingService.new(current_user: current_user, work: work) }
  let(:work) { FactoryBot.create(:data_set, creator: ['creator'], rights_license: 'rights_license', doi: doi) }
  let(:doi) { 'doi:10.82028/18sn-h641' }
  let(:pending_doi) { Deepblue::DoiBehavior::DOI_PENDING }
  let(:job_run) { DoiMintingJob.perform_now(work.id, current_user: current_user) }

  before do
    allow(Datacore::DoiMintingService).to receive(:mint_doi_for).and_return('return_value')
  end

  describe "#perform_now", :clean do
    context "when work is invalid" do
      before do
        work.title = nil
        work.save(validate: false)
        expect(work).to be_invalid
      end
      it "returns nil" do
        expect(job_run).to be_nil
      end
    end
    context "when doi blank" do
      let(:doi) { nil }
      it "returns nil" do
        expect(job_run).to be_nil
      end
    end
    context "when doi minted" do
      it "returns nil" do
        expect(job_run).to be_nil
      end
    end
    context "when doi pending" do
      let(:doi) { pending_doi }
      it "returns true" do
        expect(job_run).to eq true
      end
    end
  end
end
