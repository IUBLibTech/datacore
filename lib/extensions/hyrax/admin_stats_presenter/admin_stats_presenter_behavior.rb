module Extensions
  module Hyrax
    module AdminStatsPresenter
      module AdminStatsPresenterBehavior

        def valid_dates
          return true if date_validation
          false
        end

        def date_validation
          return true if start_date.nil?

          second_date = end_date
          second_date = Date.current if second_date.nil?
          if start_date > second_date
            stats_filters[:start_date] = nil
            stats_filters[:end_date] = nil
            return false
          end

          true
        end
      end
    end
  end
end
