module Datacore
  class CampusVisibilityService < Hyrax::QaSelectService
    def initialize
      super('iu_campuses')
    end

    def active_ids
      active_elements.map { |e| e[:id] }
    end
  end
end
