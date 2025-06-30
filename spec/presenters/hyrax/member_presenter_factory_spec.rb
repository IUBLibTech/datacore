require 'rails_helper'

RSpec.describe Hyrax::MemberPresenterFactory do

  subject { described_class.new(double, double) }

  describe 'MemberPresenterFactory class' do
    it do
      expect(Hyrax::MemberPresenterFactory.file_presenter_class).instance_of? Hyrax::DsFileSetPresenter
      expect(Hyrax::MemberPresenterFactory.work_presenter_class).instance_of? Hyrax::WorkShowPresenter
    end
  end

  describe '#initialize' do
    it "sets instance variables" do
      factory = Hyrax::MemberPresenterFactory.new("work", "ability", "request")

      factory.instance_variable_get(:@work) == "work"
      factory.instance_variable_get(:@current_ability) == "ability"
      factory.instance_variable_get(:@request) == "request"
    end
  end

  describe "delegates method to @work" do
    it "#id" do
      skip "Add a test"
    end
  end

  describe "#member_presenters" do
    before {
      allow(subject).to receive(:ordered_ids).and_return "ordered"
      allow(subject).to receive(:composite_presenter_class).and_return "composite presenter"
      allow(subject).to receive(:presenter_factory_arguments).and_return "arguments"
      allow(Hyrax::PresenterFactory).to receive(:build_for).with(ids: "ordered", presenter_class: "composite presenter", presenter_args: "arguments")
                                                    .and_return "built with arguments"
    }
    it "calls PresenterFactory.build_for" do
      expect(subject.member_presenters).to eq "built with arguments"
    end
  end

  describe "#file_set_presenters" do
    context "when @file_set_presenters has a value" do
      before {
        subject.instance_variable_set(:@file_set_presenters, "create files")
      }
      it 'returns @file_set_presenters value' do
        expect(subject).not_to receive(:member_presenters)
        expect(subject.file_set_presenters).to eq "create files"
      end
    end

    # the & symbol is intersection for arrays in Ruby  (| is union)
    context "when @file_set_presenters has no value" do
      before {
        allow(subject).to receive(:ordered_ids).and_return [ 1, 2, 3, 4, 5, 6 ]
        allow(subject).to receive(:file_set_ids).and_return [ 5, 6, 7, 8, 9, 10 ]
        allow(subject).to receive(:member_presenters).with([ 5, 6 ]).and_return "file set presenters"
      }
      it 'calls member_presenters and sets the instance variable' do
        expect(subject).to receive(:member_presenters).with( [ 5, 6 ] )
        expect(subject.file_set_presenters).to eq "file set presenters"

        subject.instance_variable_get(:@file_set_presenters) == "file set presenters"
      end
    end
  end

  describe "#work_presenters" do
    context "when @work_presenters has a value" do
      before {
        subject.instance_variable_set(:@work_presenters, "create work")
      }
      it 'returns @work_presenters value' do
        expect(subject).not_to receive(:member_presenters)
        expect(subject.work_presenters).to eq "create work"
      end
    end

    context "when @work_presenters has no value" do
      before {
        allow(subject).to receive(:ordered_ids).and_return [ 1, 2, 3, 4, 5, 6 ]
        allow(subject).to receive(:file_set_ids).and_return [ 5, 6, 7 ]
        allow(subject).to receive(:work_presenter_class).and_return "presenter class"
        allow(subject).to receive(:member_presenters).with([ 1, 2, 3, 4 ], "presenter class").and_return "member presenters"
      }
      it 'calls member_presenters and sets the instance variable' do
        expect(subject).to receive(:member_presenters).with( [ 1, 2, 3, 4 ], "presenter class" )
        expect(subject.work_presenters).to eq "member presenters"

        subject.instance_variable_get(:@work_presenters) == "member presenters"
      end
    end
  end


  describe "#ordered_ids" do
    context "when @ordered_ids has a value" do
      before {
        subject.instance_variable_set(:@ordered_ids, "create ordered works")
      }
      it 'returns @ordered_ids value' do
        expect(ActiveFedora::SolrService).not_to receive(:query)
        expect(subject.ordered_ids).to eq "create ordered works"
      end
    end
  end

  context "when @ordered_ids has no value" do
    it "calls ActiveFedora::SolrService.query and sets the instance variable" do
      skip "Add a test"
    end
  end

end
