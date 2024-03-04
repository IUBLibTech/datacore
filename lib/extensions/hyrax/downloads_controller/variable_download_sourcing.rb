# unmodified from hyrax
module Extensions
  module Hyrax
    module DownloadsController
      module VariableDownloadSourcing
        # Render the 404 page if the file doesn't exist.
        # Otherwise renders the file.
        def show
          case file
          when ActiveFedora::File
            # For original files that are stored in fedora
            super
          when String
            # For derivatives stored on the local file system
            send_local_content
          else
            raise ActiveFedora::ObjectNotFoundError
          end
        end
      end
    end
  end
end
