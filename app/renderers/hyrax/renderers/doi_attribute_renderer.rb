module Hyrax
  module Renderers

    # This is used by PresentsAttributes to show DOIs
    #   e.g.: presenter.attribute_to_html(:doi, render_as: :doi)
    class DoiAttributeRenderer < ExternalLinkAttributeRenderer
      private

        ##
        # Special treatment for DOI values.  A DOI could be  stored as:
        # 'doi:10.5967/56ck-gp62'
        # '10.5967/56ck-gp62'
        # but should be rendered as:
        # 'https://doi.org/10.5967/56ck-gp62'
        def attribute_value_to_html(value)
          case value
          when /^doi:/
            value.sub!('doi:', 'https://doi.org/')
          when /^10\./
            value = "https://doi.org/#{value}"
          when ::Deepblue::DoiBehavior::DOI_PENDING
            # FIXME: display differently?
          end
          super
        end
    end
  end
end
