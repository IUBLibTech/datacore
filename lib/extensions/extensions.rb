# extensions.rb - loads monkeypatches for samvera libraries

# handle downloads from fedora, archive server storage
Hyrax::DownloadsController.prepend Extensions::Hyrax::DownloadsController::VariableDownloadSourcing

# update obsolete URI escaping methods
Hydra::AccessControls::Permission.prepend Extensions::Hydra::AccessControls::Permission::EscapingObsoletions
ActiveFedora::File.prepend Extensions::ActiveFedora::File::EscapingObsoletions
