module Hyrax
  module Renderers

    # This is used by PresentsAttributes to show DOIs
    #   e.g.: presenter.attribute_to_html(:doi, render_as: :doi)
    class DoiAttributeRenderer < AttributeRenderer
      private

        ##
        # Special treatment for DOI values.  A DOI is stored as:
        # 'doi:10.5967/56ck-gp62'
        # but should be rendered as:
        # http://doi.org/10.5967/56ck-gp62
        def attribute_value_to_html(value)
          if value.to_s.match /^doi:/
            url = value.sub('doi:', 'https://doi.org/')
            "<a href=#{url} target=\"_blank\">#{url}</a>"
          else
            value
          end
        end
    end
  end
end
