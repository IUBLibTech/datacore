module Extensions
  module ActiveFedora
    module File
      module EscapingObsoletions
        # modified from active_fedora: update obsolete URI methods to CGI
        def ldp_headers
          headers = { 'Content-Type'.freeze => mime_type, 'Content-Length'.freeze => content.size.to_s }
          headers['Content-Disposition'.freeze] = "attachment; filename=\"#{::CGI.escape(@original_name)}\"" if @original_name
          headers
        end
      end
    end
  end
end
