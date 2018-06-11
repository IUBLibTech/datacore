# frozen_string_literal: true

class DataSet < ActiveFedora::Base

  include ::Hyrax::WorkBehavior

  self.indexer = DataSetIndexer
  # Change this to restrict which works can be added as a child.
  # self.valid_child_concerns = []
  # validates :title, presence: { message: 'Your work must have a title.' }
  ## end `rails generate hyrax:work DataSet`

  # self.human_readable_type = 'Data Set' # deprecated
  include Umrdr::UmrdrWorkBehavior
  include Umrdr::UmrdrWorkMetadata

  validates :authoremail, presence: { message: 'You must have author contact information.' }
  validates :creator, presence: { message: 'Your work must have a creator.' }
  validates :description, presence: { message: 'Your work must have a description.' }
  validates :methodology, presence: { message: 'Your work must have a description of the method for collecting the dataset.' }
  validates :rights_license, presence: { message: 'You must select a license for your work.' }
  validates :title, presence: { message: 'Your work must have a title.' }

  ## begin `rails generate hyrax:work DataSet`
  # This must be included at the end, because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)

  include ::Deepblue::DefaultMetadata
  include ::Deepblue::ProvenanceBehavior

  after_initialize :set_defaults
  
  before_destroy :provenance_before_destroy_data_set

  def provenance_before_destroy_data_set
    provenance_destroy( current_user: '' ) # , event_note: 'provenance_before_destroy_data_set' )
  end

  PENDING = 'pending'

  def set_defaults
    return unless new_record?
    self.resource_type = ["Dataset"]
  end

  def attributes_all_for_provenance
    %i[
      admin_set_id
      authoremail
      creator
      date_created
      date_modified
      date_updated
      date_coverage
      description
      doi
      fundedby
      grantnumber
      isReferencedBy
      keyword
      language
      location
      methodology
      rights_license
      subject_discipline
      title
      tombstone
      total_file_count
      total_file_size
      total_file_size_human_readable
      visibility
    ]
  end

  def attributes_brief_for_provenance
    %i[
      admin_set_id
      authoremail
      title
      visibility
    ]
  end

  def for_provenance_route
    Rails.application.routes.url_helpers.hyrax_data_set_path( id: id )
  end

  def map_provenance_attributes_override!( event:, # rubocop:disable Lint/UnusedMethodArgument
                                           attribute:,
                                           ignore_blank_key_values:,
                                           prov_key_values: )
    value = nil
    handled = case attribute.to_s
              when 'total_file_count'
                value = total_file_count
                true
              when 'total_file_size_human_readable'
                value = total_file_size_human_readable
                true
              when 'visibility'
                value = visibility
                true
              else
                false
              end
    return false unless handled
    if ignore_blank_key_values
      prov_key_values[attribute] = value if value.present?
    else
      prov_key_values[attribute] = value
    end
    return true
  end

  # # Visibility helpers
  # def private?
  #   visibility == Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE
  # end
  #
  # def public?
  #   visibility == Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
  # end

  # the list of creators is ordered
  def creator
    values = super
    values = MetadataHelper.ordered( ordered_values: creator_ordered, values: values )
    return values
  end

  def creator=( values )
    self.creator_ordered = MetadataHelper.ordered_values( ordered_values: creator_ordered, values: values )
    super values
  end

  # the list of description is ordered
  def description
    values = super
    values = MetadataHelper.ordered( ordered_values: description_ordered, values: values )
    return values
  end

  def description=( values )
    self.description_ordered = MetadataHelper.ordered_values( ordered_values: description_ordered, values: values )
    super values
  end

  #
  # Make it so work does not show up in search result for anyone, not even admins.
  #
  def entomb!( epitaph, current_user )
    return if tombstone.present?
    provenance_tombstone( current_user: current_user )
    self.visibility = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE
    self.depositor = 'TOMBSTONE-' + depositor
    self.tombstone = [epitaph]

    file_sets.each do |file_set|
      # TODO: FileSet#entomb!
      file_set.visibility = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE
    end

    save
  end

  #
  # handle the list of isReferencedBy as ordered
  #
  def isReferencedBy # rubocop:disable Style/MethodName
    values = super
    values = MetadataHelper.ordered( ordered_values: isReferencedBy_ordered, values: values )
    return values
  end

  def isReferencedBy=( values ) # rubocop:disable Style/MethodName
    self.isReferencedBy_ordered = MetadataHelper.ordered_values( ordered_values: isReferencedBy_ordered, values: values )
    super values
  end

  #
  # the list of keyword is ordered
  #
  def keyword
    values = super
    values = MetadataHelper.ordered( ordered_values: keyword_ordered, values: values )
    return values
  end

  def keyword=( values )
    self.keyword_ordered = MetadataHelper.ordered_values( ordered_values: keyword_ordered, values: values )
    super values
  end

  #
  # handle the list of language as ordered
  #
  def language
    values = super
    values = MetadataHelper.ordered( ordered_values: language_ordered, values: values )
    return values
  end

  def language=( values )
    self.language_ordered = MetadataHelper.ordered_values( ordered_values: language_ordered, values: values )
    super values
  end

  # hthe list of title is ordered
  def title
    values = super
    values = MetadataHelper.ordered( ordered_values: title_ordered, values: values )
    return values
  end

  def title=( values )
    self.title_ordered = MetadataHelper.ordered_values( ordered_values: title_ordered, values: values )
    super values
  end

  def total_file_count
    return 0 if file_set_ids.blank?
    file_set_ids.size
  end

end
