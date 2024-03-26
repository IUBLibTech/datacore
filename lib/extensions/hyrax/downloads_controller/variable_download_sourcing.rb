# modified from hyrax for bypass_fedora case
module Extensions
  module Hyrax
    module DownloadsController
      module VariableDownloadSourcing
        # Render the 404 page if the file doesn't exist.
        # Otherwise renders the file.
        def show
          case file
          when ActiveFedora::File
            case file.mime_type
            when /access-type=URL/
              # for original files that bypass fedora
              redirect_to file.file_name.first # file_name contains archival controller path
            else
              # For original files that are stored in fedora
              super
            end
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
