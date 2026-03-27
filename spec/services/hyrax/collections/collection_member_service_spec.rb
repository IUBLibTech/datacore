require 'rails_helper'

RSpec.describe Hyrax::Collections::CollectionMemberService do

  subject { described_class.new(scope: "scoped", collection: "collected", params: "parameterized")}

  describe '#initialize' do
    it "sets instance variables" do
      member_service = Hyrax::Collections::CollectionMemberService.new(scope: "the scope", collection: "the collection", params: "the parameters")

      expect(member_service.instance_variable_get(:@scope)).to eq "the scope"
      expect(member_service.instance_variable_get(:@collection)).to eq "the collection"
      expect(member_service.instance_variable_get(:@params)).to eq "the parameters"
    end
  end


  describe "#available_member_subcollections" do
    before {
      allow(Deepblue::LoggingHelper).to receive(:here).and_return "here"
      allow(Deepblue::LoggingHelper).to receive(:called_from).and_return "called from"
      allow(subject).to receive(:subcollections_search_builder).and_return "subcollections search builder"
      allow(subject).to receive(:params_for_subcollections).and_return "params for subcollections"

      allow(subject).to receive(:query_solr).with(query_builder: "subcollections search builder", query_params: "params for subcollections")
    }

    it "calls subcollections_search_builder and params_for_subcollections, then calls query_solr with the results" do
      expect(subject).to receive(:subcollections_search_builder).twice
      expect(subject).to receive(:params_for_subcollections).twice
      expect(Deepblue::LoggingHelper).to receive(:bold_debug).with [ "here", "called from", "subcollections_search_builder=subcollections search builder",
                                                                     "params_for_subcollections=params for subcollections", "" ]
      expect(subject).to receive(:query_solr).with(query_builder: "subcollections search builder", query_params: "params for subcollections")

      subject.available_member_subcollections
    end
  end


  describe "#available_member_works" do
    before {
      allow(Deepblue::LoggingHelper).to receive(:here).and_return "here"
      allow(Deepblue::LoggingHelper).to receive(:called_from).and_return "called from"
      allow(subject).to receive(:works_search_builder).and_return "works search builder"

      allow(subject).to receive(:query_solr).with(query_builder: "works search builder", query_params: "parameterized")

    }

    it "calls works_search_builder and calls query_solr with the results" do
      expect(subject).to receive(:works_search_builder).twice

      expect(Deepblue::LoggingHelper).to receive(:bold_debug).with [ "here", "called from", "works_search_builder=works search builder",
                                                                     "params=parameterized", "" ]
      expect(subject).to receive(:query_solr).with(query_builder: "works search builder", query_params: "parameterized")

      subject.available_member_works
    end
  end


  describe "#available_member_work_ids" do
    before {
      allow(subject).to receive(:work_ids_search_builder).and_return "work ids search builder"
      allow(subject).to receive(:query_solr_with_field_selection).with(query_builder: "work ids search builder", fl: 'id')
    }

    it "calls work_ids_search_builder and calls query_solr_with_field_selection with the results" do
      expect(subject).to receive(:work_ids_search_builder).and_return "work ids search builder"
      expect(subject).to receive(:query_solr_with_field_selection).with(query_builder: "work ids search builder", fl: 'id')

      subject.available_member_work_ids
    end
  end


  # private methods

  describe "#works_search_builder" do
    before {
      allow(Hyrax::CollectionMemberSearchBuilder).to receive(:new).with(scope: "scoped", collection: "collected", search_includes_models: :works)
                                                                  .and_return "works search builder"
    }
    context "when @works_search_builder has NO value" do
      it "calls CollectionMemberSearchBuilder.new, sets instance variable, and returns value" do
        subject.send(:works_search_builder)

        expect(subject.instance_variable_get(:@works_search_builder)).to eq "works search builder"
      end
    end

    context "when @works_search_builder has a value" do
      before {
        subject.instance_variable_set(:@works_search_builder, "valued")
      }
      it "returns value" do
        subject.send(:works_search_builder)

        expect(subject.instance_variable_get(:@works_search_builder)).to eq "valued"
      end
    end
  end


  describe "#subcollections_search_builder" do
    before {
      allow(Hyrax::CollectionMemberSearchBuilder).to receive(:new).with(scope: "scoped", collection: "collected", search_includes_models: :collections)
                                                                  .and_return "subcollections search builder"
    }
    context "when @subcollections_search_builder has NO value" do
      it "calls CollectionMemberSearchBuilder.new, sets instance variable, and returns value" do
        subject.send(:subcollections_search_builder)

        expect(subject.instance_variable_get(:@subcollections_search_builder)).to eq "subcollections search builder"
      end
    end

    context "when @subcollections_search_builder has a value" do
      before {
        subject.instance_variable_set(:@subcollections_search_builder, "valuization")
      }
      it "returns value" do
        subject.send(:subcollections_search_builder)

        expect(subject.instance_variable_get(:@subcollections_search_builder)).to eq "valuization"
      end
    end
  end


  describe "#work_ids_search_builder" do
    before {
      allow(Hyrax::CollectionMemberSearchBuilder).to receive(:new).with(scope: "scoped", collection: "collected", search_includes_models: :works)
                                                                  .and_return "work ids search builder"
    }
    context "when @work_ids_search_builder has NO value" do
      it "calls CollectionMemberSearchBuilder.new, sets instance variable, and returns value" do
        subject.send(:work_ids_search_builder)

        expect(subject.instance_variable_get(:@work_ids_search_builder)).to eq "work ids search builder"
      end
    end

    context "when @work_ids_search_builder has a value" do
      before {
        subject.instance_variable_set(:@work_ids_search_builder, "value-icious")
      }
      it "returns value" do
        subject.send(:work_ids_search_builder)

        expect(subject.instance_variable_get(:@work_ids_search_builder)).to eq "value-icious"
      end
    end
  end


  pending "#query_solr"

  pending "#query_solr_with_field_selection"


  describe "#params_for_subcollections" do
    before {
      subject.instance_variable_set(:@params, {:sub_collection_page => "47", :another => true})
    }
    it "sets page to sub_collection_page, deletes sub_collection_page from params, and returns params" do
      expect(subject.send(:params_for_subcollections)).to eq :page => "47", :another => true
    end
  end

end