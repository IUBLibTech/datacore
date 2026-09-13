module Hyrax
  class RenderPresentValueService < QaSelectService

    def initialize(service_name)
      super(service_name)
    end

    def include_current_value( value, _index, render_options, html_options )
      # unless value.blank? || active?(value)
      if value.present?
        html_options[:class] << ' force-select'
        render_options += [[label(value), value]]
      end
      [render_options, html_options]
    end
  end

end
