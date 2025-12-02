# extensions.rb - loads monkeypatches for samvera libraries

# handle downloads from fedora, archive server storage
Hyrax::DownloadsController.prepend Extensions::HyraxExtensions::DownloadsController::VariableDownloadSourcing

# update obsolete URI escaping methods
Hydra::AccessControls::Permission.prepend Extensions::Hydra::AccessControls::Permission::EscapingObsoletions
ActiveFedora::File.prepend Extensions::ActiveFedora::File::EscapingObsoletions

# Collections search
Qa::Authorities::Collections.prepend Extensions::Qa::Authorities::Collections::CollectionsSearch

# return false for render_bookmarks_control? in CollectionsController
Hyrax::CollectionsController.prepend Extensions::HyraxExtensions::CollectionsController::RenderBookmarksControl
Hyrax::My::CollectionsController.prepend Extensions::HyraxExtensions::CollectionsController::RenderBookmarksControl

# Statistics By Date Report page
Hyrax::AdminStatsPresenter.prepend Extensions::HyraxExtensions::AdminStatsPresenter::AdminStatsPresenterBehavior

# accessibility improvements
Hyrax::CollapsableSectionPresenter.prepend Extensions::HyraxExtensions::CollapsableSectionPresenter::CollapsableSectionPresenterBehavior

# adding Featured Collections
Hyrax::HomepageController.prepend Extensions::HyraxExtensions::HomepageController::HomepageControllerBehavior

# adding reCAPTCHA
Hyrax::ContactFormController.prepend Extensions::HyraxExtensions::ContactFormController::ContactFormControllerBehavior
