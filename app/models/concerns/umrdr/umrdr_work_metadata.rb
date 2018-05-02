module Umrdr
  module UmrdrWorkMetadata
    extend ActiveSupport::Concern
    included do

      property :authoremail, predicate: ::RDF::Vocab::FOAF.mbox, multiple: false do |index|
        index.type :text
        index.as :stored_searchable
      end

      property :creator_ordered, predicate: ::RDF::Vocab::MODS.name, multiple: false do |index|
        index.type :text
        index.as :stored_searchable
      end

      property :date_coverage, predicate: ::RDF::Vocab::DC.temporal, multiple: true do |index|
        index.type :text
        index.as :stored_searchable, :facetable
      end

      property :description_ordered, predicate: ::RDF::URI.new('https://deepblue.lib.umich.edu/data/help.help#description_ordered'), multiple: false do |index|
        index.type :text
        index.as :stored_searchable
      end

      property :doi, predicate: ::RDF::Vocab::Identifiers.doi, multiple: false

      property :fundedby, predicate: ::RDF::Vocab::DISCO.fundedBy, multiple: true do |index|
        index.type :text
        index.as :stored_searchable
      end

      property :grantnumber, predicate: ::RDF::URI.new('http://purl.org/cerif/frapo/hasGrantNumber'), multiple: false do |index|
        index.type :text
        index.as :stored_searchable
      end

      property :hdl, predicate: ::RDF::Vocab::Identifiers.hdl, multiple: false

      property :isReferencedBy, predicate: ::RDF::Vocab::DC.isReferencedBy, multiple: true do |index|
        index.type :text
        index.as :stored_searchable
      end

      property :isReferencedBy_ordered, predicate: ::RDF::URI.new('https://deepblue.lib.umich.edu/data/help.help#isReferencedBy_ordered'), multiple: false do |index|
        index.type :text
        index.as :stored_searchable
      end

      property :keyword_ordered, predicate: ::RDF::URI.new('https://deepblue.lib.umich.edu/data/help.help#keyword_ordered'), multiple: false do |index|
        index.type :text
        index.as :stored_searchable
      end

      property :language_ordered, predicate: ::RDF::URI.new('https://deepblue.lib.umich.edu/data/help.help#language_ordered'), multiple: false do |index|
        index.type :text
        index.as :stored_searchable
      end

      property :methodology, predicate: ::RDF::URI.new('http://www.ddialliance.org/Specification/DDI-Lifecycle/3.2/XMLSchema/FieldLevelDocumentation/schemas/datacollection_xsd/elements/DataCollectionMethodology.html'), multiple: false do |index|
        index.type :text
        index.as :stored_searchable
      end

      property :subject, predicate: ::RDF::Vocab::MODS.subject

      property :title_ordered, predicate: ::RDF::URI.new('https://deepblue.lib.umich.edu/data/help.help#title_ordered'), multiple: false do |index|
        index.type :text
        index.as :stored_searchable
      end

      property :tombstone, predicate: ::RDF::Vocab::DC.provenance, multiple: true do |index|
        index.type :text
        index.as :stored_searchable
      end

      property :total_file_size, predicate: ::RDF::Vocab::DC.SizeOrDuration, multiple: false

      # TODO: can't use the same predicate twice
      #property :total_file_size_human_readable, predicate: ::RDF::Vocab::DC.SizeOrDuration, multiple: false

    end
  end
end