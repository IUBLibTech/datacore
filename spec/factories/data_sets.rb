# frozen_string_literal: true

FactoryBot.define do
  factory :data_set, aliases: [:data_set_work], class: ::DataSet do
    title { ["Test title"] }
    visibility { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE }
    authoremail { "test@iu.edu" }
    description { ["This is the description."] }
    methodology { "The Methodology" }
    creator { ['creator1'] }
    rights_license { "http://creativecommons.org/publicdomain/zero/1.0/" }
    rights_statement { ["http://rightsstatements.org/vocab/NKC/1.0/"] }

    transient do
      user { create(:user) }
      # Set to true (or a hash) if you want to create an admin set
      with_admin_set { false }
    end

    # It is reasonable to assume that a work has an admin set; However, we don't want to
    # go through the entire rigors of creating that admin set.
    before(:create) do |work, evaluator|
      if evaluator.with_admin_set
        attributes = {}
        attributes[:id] = work.admin_set_id if work.admin_set_id.present?
        attributes = evaluator.with_admin_set.merge(attributes) if evaluator.with_admin_set.respond_to?(:merge)
        admin_set = create(:admin_set, attributes)
        work.admin_set_id = admin_set.id
      end
    end

    after(:create) do |work, _evaluator|
      work.save! if work.member_of_collections.present?
    end

    after(:build) do |work, evaluator|
      work.apply_depositor_metadata(evaluator.user.user_key)
    end

    factory :public_data_set, aliases: [:public_data_set_data_set], traits: [:public]

    trait :public do
      visibility { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC }
    end

    factory :private_data_set do
      # visibility Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE
    end

    factory :registered_data_set do
      read_groups { ["registered"] }
    end

    factory :data_set_with_one_file do
      before(:create) do |work, evaluator|
        work.ordered_members << create(:file_set, user: evaluator.user, title: ['A Contained FileSet'], label: 'filename.pdf')
      end
    end

    factory :data_set_with_files do
      before(:create) { |work, evaluator| 2.times { work.ordered_members << create(:file_set, user: evaluator.user) } }
    end

    factory :data_set_with_ordered_files do
      before(:create) do |work, evaluator|
        work.ordered_members << create(:file_set, user: evaluator.user)
        work.ordered_member_proxies.insert_target_at(0, create(:file_set, user: evaluator.user))
      end
    end

    factory :data_set_with_one_child do
      before(:create) do |work, evaluator|
        work.ordered_members << create(:work, user: evaluator.user, title: ['A Contained Work'])
      end
    end

    factory :data_set_with_two_children do
      before(:create) do |work, evaluator|
        work.ordered_members << create(:work, user: evaluator.user, title: ['A Contained Work'], id: "BlahBlah1")
        work.ordered_members << create(:work, user: evaluator.user, title: ['Another Contained Work'], id: "BlahBlah2")
      end
    end

    factory :data_set_with_representative_file do
      before(:create) do |work, evaluator|
        work.ordered_members << create(:file_set, user: evaluator.user, title: ['A Contained FileSet'])
        work.representative_id = work.members[0].id
      end
    end

    factory :data_set_with_file_and_data_set do
      before(:create) do |work, evaluator|
        work.ordered_members << create(:file_set, user: evaluator.user)
        work.ordered_members << create(:work, user: evaluator.user)
      end
    end

    factory :with_embargo_date do
      # build with defaults:
      # let(:work) { create(:embargoed_data_set) }

      # build with specific values:
      # let(:embargo_attributes) do
      #   { embargo_date: Date.tomorrow.to_s,
      #     current_state: Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE,
      #     future_state: Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC }
      # end
      # let(:work) { create(:embargoed_data_set, with_embargo_attributes: embargo_attributes) }

      transient do
        with_embargo_attributes { false }
        embargo_date { Date.tomorrow.to_s }
        current_state { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE }
        future_state { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC }
      end
      factory :embargoed_data_set do
        after(:build) do |work, evaluator|
          if evaluator.with_embargo_attributes
            work.apply_embargo(evaluator.with_embargo_attributes[:embargo_date],
                               evaluator.with_embargo_attributes[:current_state],
                               evaluator.with_embargo_attributes[:future_state])
          else
            work.apply_embargo(evaluator.embargo_date,
                               evaluator.current_state,
                               evaluator.future_state)
          end
        end
      end
      factory :embargoed_data_set_with_files do
        after(:build) do |work, evaluator|
          if evaluator.with_embargo_attributes
            work.apply_embargo(evaluator.with_embargo_attributes[:embargo_date],
                               evaluator.with_embargo_attributes[:current_state],
                               evaluator.with_embargo_attributes[:future_state])
          else
            work.apply_embargo(evaluator.embargo_date,
                               evaluator.current_state,
                               evaluator.future_state)
          end
        end
        after(:create) { |work, evaluator| 2.times { work.ordered_members << create(:file_set, user: evaluator.user) } }
      end
    end

    factory :with_lease_date do
      # build with defaults:
      # let(:work) { create(:leased_data_set) }

      # build with specific values:
      # let(:lease_attributes) do
      #   { lease_date: Date.tomorrow.to_s,
      #     current_state: Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC,
      #     future_state: Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_AUTHENTICATED }
      # end
      # let(:work) { create(:leased_data_set, with_lease_attributes: lease_attributes) }

      transient do
        with_lease_attributes { false }
        lease_date { Date.tomorrow.to_s }
        current_state { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC }
        future_state { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE }
      end
      factory :leased_data_set do
        after(:build) do |work, evaluator|
          if evaluator.with_lease_attributes
            work.apply_lease(evaluator.with_lease_attributes[:lease_date],
                             evaluator.with_lease_attributes[:current_state],
                             evaluator.with_lease_attributes[:future_state])
          else
            work.apply_lease(evaluator.lease_date,
                             evaluator.current_state,
                             evaluator.future_state)
          end
        end
      end
      factory :leased_data_set_with_files do
        after(:build) do |work, evaluator|
          if evaluator.with_lease_attributes
            work.apply_lease(evaluator.with_lease_attributes[:lease_date],
                             evaluator.with_lease_attributes[:current_state],
                             evaluator.with_lease_attributes[:future_state])
          else
            work.apply_lease(evaluator.lease_date,
                             evaluator.current_state,
                             evaluator.future_state)
          end
        end
        after(:create) { |work, evaluator| 2.times { work.ordered_members << create(:file_set, user: evaluator.user) } }
      end
    end
  end

  # Doesn't set up any edit_users
  factory :data_set_without_access, class: DataSet do
    title { ['Test title'] }
    depositor { create(:user).user_key }
  end
end
