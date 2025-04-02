module Extensions
  module Hyrax
    module AdminStatsPresenter
      module AdminStatsPresenterBehavior

        def valid_dates
          clear_invalid_dates!
          start_date.nil? || start_date <= second_date
        end

        def second_date
          end_date || Date.current
        end

        def clear_invalid_dates!
          if start_date && start_date > second_date
            stats_filters[:start_date] = nil
            stats_filters[:end_date] = nil
          end
        end
      end
    end
  end
end
