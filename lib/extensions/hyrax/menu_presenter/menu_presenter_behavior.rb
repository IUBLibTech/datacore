module Extensions
  module Hyrax
    module MenuPresenter
      module MenuPresenterBehavior

        def settings_section?
          %w[appearances content_blocks features pages collection_types rack_attacks robots].include?(controller_name)
        end

      end
    end
  end
end
