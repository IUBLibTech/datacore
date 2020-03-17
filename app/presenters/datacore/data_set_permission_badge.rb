module Datacore
  class DataSetPermissionBadge < ::Hyrax::PermissionBadge

    def initialize(visibility, campuses)
      super(visibility)
      @campuses = campuses
    end

    def render
      output = super
      if !@campuses.blank?
        @campuses.each do |c|
          output += content_tag(:span, c, class: "label #{dom_label_class}")
        end
      end
      output
    end
  end
end
