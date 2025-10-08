# extensions.rb - loads monkeypatches for samvera libraries

# handle downloads from fedora, archive server storage
Hyrax::DownloadsController.prepend Extensions::Hyrax::DownloadsController::VariableDownloadSourcing

# update obsolete URI escaping methods
Hydra::AccessControls::Permission.prepend Extensions::Hydra::AccessControls::Permission::EscapingObsoletions
ActiveFedora::File.prepend Extensions::ActiveFedora::File::EscapingObsoletions

# Collections search
Qa::Authorities::Collections.prepend Extensions::Qa::Authorities::Collections::CollectionsSearch

# return false for render_bookmarks_control? in CollectionsController
Hyrax::CollectionsController.prepend Extensions::Hyrax::CollectionsController::RenderBookmarksControl
Hyrax::My::CollectionsController.prepend Extensions::Hyrax::CollectionsController::RenderBookmarksControl

# Statistics By Date Report page
Hyrax::AdminStatsPresenter.prepend Extensions::Hyrax::AdminStatsPresenter::AdminStatsPresenterBehavior

# accessibility improvements
Hyrax::CollapsableSectionPresenter.prepend Extensions::Hyrax::CollapsableSectionPresenter::CollapsableSectionPresenterBehavior

# adding Featured Collections
Hyrax::HomepageController.prepend Extensions::Hyrax::HomepageController::HomepageControllerBehavior
