module Extensions
  module Hyrax
    module MenuPresenter
      module MenuPresenterBehavior

        def settings_section?
          %w[appearances content_blocks features pages collection_types].include?(controller_name)
        end

      end
    end
  end
end
