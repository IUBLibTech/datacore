# extensions.rb - loads monkeypatches for samvera libraries

Hyrax::DownloadsController.prepend Extensions::Hyrax::DownloadsController::VariableDownloadSourcing

# Collections search
Qa::Authorities::Collections.prepend Extensions::Qa::Authorities::Collections::CollectionsSearch
