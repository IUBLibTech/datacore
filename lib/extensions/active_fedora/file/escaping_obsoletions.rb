module Extensions
  module ActiveFedora
    module File
      module EscapingObsoletions
        # unmodified from active_fedora
        def ldp_headers
          headers = { 'Content-Type'.freeze => mime_type, 'Content-Length'.freeze => content.size.to_s }
          headers['Content-Disposition'.freeze] = "attachment; filename=\"#{::URI.encode(@original_name)}\"" if @original_name
          headers
        end
      end
    end
  end
end
