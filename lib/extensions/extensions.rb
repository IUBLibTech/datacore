# extensions.rb - loads monkeypatches for samvera libraries

Hyrax::DownloadsController.prepend Extensions::Hyrax::DownloadsController::VariableDownloadSourcing
