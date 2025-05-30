require 'rails_helper'

RSpec.describe Hyrax::HomepagePresenter do
  let(:user) { FactoryBot.create :user }
  let(:current_ability) { instance_double(Ability, current_user: user ) }
  let(:blacklight_config) { Blacklight::Configuration.new }
  let(:collections) { Hyrax::CollectionSearchBuilder.new(self).rows(1) }

  subject{ described_class.new(current_ability, collections) }

  describe '#create_work_presenter_class' do
    it do
      expect(Hyrax::HomepagePresenter.create_work_presenter_class).instance_of?(Hyrax::SelectTypeListPresenter)
    end
  end

  describe '#initialize' do
    it "sets instance variables using parameters" do
      present = Hyrax::HomepagePresenter.new("current ability", "collections")

      present.instance_variable_get(:@current_ability) == "current ability"
      present.instance_variable_get(:@collections) == "collections"
    end
  end

  describe "#display_share_button?" do
      expected_results = [OpenStruct.new( user_unregistered: true, not_logged_in: true, can_create: true, expected_result: true ),
                          OpenStruct.new( user_unregistered: false, not_logged_in: false, can_create: true, expected_result: true ),
                          OpenStruct.new( user_unregistered: true, not_logged_in: false, can_create: false, expected_result: false ),
                          OpenStruct.new( user_unregistered: false, not_logged_in: true, can_create: false, expected_result: false ),
                          OpenStruct.new( user_unregistered: false, not_logged_in: false, can_create: false, expected_result: false )]

      expected_results.each { |n|
        context "when user_unregistered? is #{n.user_unregistered}, display_share_button_when_not_logged_in? is #{n.not_logged_in}, and can_create_any_work? is #{n.can_create}" do
          before {
            allow(subject).to receive(:user_unregistered?).and_return n.user_unregistered
            allow(Hyrax.config).to receive(:display_share_button_when_not_logged_in?).and_return n.not_logged_in
            allow(subject.current_ability).to receive(:can_create_any_work?).and_return n.can_create
          }
          it "returns #{n.expected_result}" do
            expect(subject).to receive(:user_unregistered?)

            if n.user_unregistered
              expect(Hyrax.config).to receive(:display_share_button_when_not_logged_in?)
            else
              expect(Hyrax.config).not_to receive(:display_share_button_when_not_logged_in?)
            end

            if !n.user_unregistered or !n.not_logged_in
              expect(subject.current_ability).to receive(:can_create_any_work?)
            else
              expect(subject.current_ability).not_to receive(:can_create_any_work?)
            end

            expect(subject.display_share_button?).to eq(n.expected_result)
          end
        end
      }
  end

  describe "#create_work_presenter" do
    context "when @create_work_presenter has a value" do
      before {
        subject.instance_variable_set(:@create_work_presenter, "create work")
      }
      it 'returns @create_work_presenter value' do
        expect(subject.create_work_presenter_class).not_to receive(:new).with(user)
        expect(subject.create_work_presenter).to eq "create work"
      end
    end

    context "when @create_work_presenter has no value" do
      before {
        allow(subject.create_work_presenter_class).to receive(:new).with(user).and_return "new class"
      }
      it 'calls create_work_presenter_class.new and sets instance variable' do
        expect(subject.create_work_presenter_class).to receive(:new).with(user)
        expect(subject.create_work_presenter).to eq "new class"

        subject.instance_variable_get(:@create_work_presenter) == "new class"
      end
    end
  end

  describe "#create_many_work_types?" do
    before {
      allow(subject.create_work_presenter).to receive(:many?).and_return true
    }

    context "when Flipflop.only_use_data_set_work_type? is true" do
      before {
        allow(Flipflop).to receive(:only_use_data_set_work_type?).and_return true
      }
      it "returns false" do
        expect(subject.create_work_presenter).not_to receive(:many?)

        expect(subject.create_many_work_types?).to eq false
      end
    end

    context "when Flipflop.only_use_data_set_work_type? is false" do
      before {
        allow(Flipflop).to receive(:only_use_data_set_work_type?).and_return false
      }
      it "returns create_work_presenter.many?" do
        expect(subject.create_work_presenter).to receive(:many?)

        expect(subject.create_many_work_types?).to eq true
      end
    end

    after {
      expect(Flipflop).to have_received(:only_use_data_set_work_type?)
    }
  end

  describe "#draw_select_work_modal?" do
    factors = [{"display" => true, "create" => true, "expected_result" => true},
       {"display" => false, "create" => false, "expected_result" => false},
       {"display" => true, "create" => false, "expected_result" => false},
       {"display" => false, "create" => true, "expected_result" => false}]

    factors.each { |factor|
      context "display_share_button? is #{factor[:display]} and create_many_work_types? is #{factor[:create]}" do |it|
        before {
          allow(subject).to receive(:display_share_button?).and_return factor[:display]
          allow(subject).to receive(:create_many_work_types?).and_return factor[:create]
        }
        it "returns #{factor[:expected_result]}" do
          expect(subject).to receive(:display_share_button?)

          if factor[:display]
            expect(subject).to receive(:create_many_work_types?)
          end

          expect(subject.draw_select_work_modal?).to eq factor[:expected_result]
        end
      end
    }
  end


  describe "#first_work_type" do
    context "create_work_presenter has at least one model" do
      before {
        allow(subject.create_work_presenter).to receive(:authorized_models).and_return ["Uno", "Dos"]
      }
      it "returns first model" do
        expect(subject.first_work_type).to eq "Uno"
      end
    end
  end


end
