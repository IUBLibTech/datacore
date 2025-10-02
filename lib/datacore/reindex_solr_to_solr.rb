module Datacore
  class ReindexSolrToSolr

    # Only url is needed for new solr but other config options can be passed in addition
    attr_accessor :old_solr, :new_solr

    def initialize(new_solr_config:, old_solr_config:)
      @old_solr = ActiveFedora::SolrService.new(old_solr_config) if old_solr_config.present?
      @old_solr ||= ActiveFedora.solr
      @new_solr = ActiveFedora::SolrService.new(new_solr_config)
    end

    # Example reindexing a delta via query: "timestamp:[#{(DateTime.now - 1.day).utc.iso8601} TO *]"
    def reindex(query: "*", batch_size: 1000)
      puts "Old solr: #{@old_solr.conn.uri.to_s}"
      puts "New solr: #{@new_solr.conn.uri.to_s}"

      total_docs = old_solr.conn.get('select', params: {q: query, rows: 0})["response"]["numFound"]
      if total_docs == 0
        puts "No documents found to reindex."
        return
      end

      puts "Starting reindex of #{total_docs} docs at #{DateTime.now.utc.iso8601}"
      docs_processed = total_docs_processed = 0
      while docs_processed < total_docs
        docs = old_solr.conn.get('select', params: {q: query, fl: '*', sort: 'timestamp asc', rows: batch_size, start: docs_processed})["response"]["docs"]

        reconstructed_docs = docs.collect do |doc|
          SolrDocReconstructor.new(doc).reconstruct
        rescue RuntimeError => e
          puts "Error reconstructing #{doc["id"]}...falling back to ActiveFedora method"
          puts e.message
          begin
            ActiveFedora::Base.find(doc["id"]).to_solr
          rescue Ldp::Gone
            puts "Object no longer exists in Fedora (Ldp::Gone)"
          rescue RuntimeError => e2
            puts "Error reindexing from Fedora"
            puts e.message
          end
        end

        reconstructed_docs.compact!
        new_solr.conn.add(reconstructed_docs, {softCommit: true})
        docs_processed += docs.size
        total_docs_processed += reconstructed_docs.size
        puts "Migrated #{total_docs_processed} out of #{total_docs}"
      end
      puts "Committing..."
      new_solr.conn.commit
      puts "Optimizing..."
      new_solr.conn.optimize
      puts "Complete at #{DateTime.now.utc.iso8601}"
    end

    class SolrDocReconstructor
      STORED_DEFINITIONS = ["stored_searchable", "stored_sortable", "displayable", "symbol"]
      NON_STORED_DEFINITIONS = ["facetable", "searchable", "sortable"]

      attr_accessor :doc
      
      def initialize(doc)
        @doc = doc
      end

      def reconstruct
        klass = detect_class(doc)
        new_doc = doc.except("timestamp", "score", "_version_")
        reconstruct_class(new_doc, klass)
        reconstruct_includes(new_doc, klass)
        new_doc
      end

      private

      def detect_class(doc)
        doc["has_model_ssim"]&.first&.safe_constantize || Object
      end

      def find_value(field, stored_def, new_doc)
        case stored_def
        when "stored_searchable"
          new_doc["#{field}_tesim"] || new_doc["#{field}_dtsim"] || new_doc["#{field}_isim"]
        when "displayable"
          new_doc["#{field}_ssm"]
        when "symbol"
          new_doc["#{field}_ssim"]
        when "stored_sortable"
          new_doc["#{field}_ssi"] || new_doc["#{field}_dtsi"]
        default
          nil
        end
      end

      def find_value_type(value)
        case value
        when String
          :string
        when Integer
          :integer
        when DateTime
          :time
        when TrueClass, FalseClass
          :boolean
        when Array
          find_value_type(value.first)
        end
      end

      def set_value(field, non_store_def, value, new_doc)
          value_type = find_value_type(value)
          case non_store_def
          when "facetable"
            new_doc["#{field}_sim"] = value
          when "searchable"
            if value_type == :string
              new_doc["#{field}_teim"] = value
            elsif value_type == :time
              new_doc["#{field}_dtim"] = value
            elsif value_type == :integer
              new_doc["#{field}_iim"] = value
            end
          when "unstemmed_searchable"
            new_doc["#{field}_tim"] = value
          end
      end

      # Characterization terms (e.g. width, height) are all stored and defined in Hyrax::FileSetIndexer

      # Hyrax::CoreMetadata
      CORE_METADATA_FIELDS = {
        "title_sim" => "title_tesim"
      }

      # Hyrax::HumanReadableType
      HUMAN_READABLE_FIELDS = {
        "human_readable_type_sim" => "human_readable_type_tesim"
      }

      # TODO: Make this more introspective?  For now this list works for all ESSI works
      BASIC_METADATA_FIELDS = {
        # Hyrax::BasicMetadataIndexer.stored_and_facetable_fields
        # klass.indexer.new(nil).rdf_service.stored_and_facetable_fields also includes date_created
        "resource_type_sim" => "resource_type_tesim",
        "creator_sim" => "creator_tesim",
        "contributor_sim" => "contributor_tesim",
        "keyword_sim" => "keyword_tesim",
        "publisher_sim" => "publisher_tesim",
        "subject_sim" => "subject_tesim",
        "language_sim" => "language_tesim",
        "date_created_sim" => "date_created_tesim",

        # klass.controlled_properties in Hyrax::DeepIndexingService
        "based_near_sim" => "based_near_tesim",
        "based_near_label_sim" => "based_near_label_tesim"
      }

      # FIXME: change to "additional"
      def reconstruct_dynamic_fields(new_doc)
        properties = DataSet.properties # FIXME: drop things covered by constant arrays for modules
        problem_fields = []
        properties.each do |field, field_def|
          # next unless field_def.behaviors.any?
          non_stored = (field_def.behaviors || []).map(&:to_s) & NON_STORED_DEFINITIONS
          next unless non_stored.present?
          stored = field_def.behaviors.map(&:to_s) & STORED_DEFINITIONS
          unless stored.present?
            problem_fields += [field]
            next
          end
          value = find_value(field, Array(stored).first, new_doc)
          next unless value.present?
          non_stored.each { |non_store_def| set_value(field, non_store_def, value, new_doc) }
        end
        raise "Unable to reindex (Problem fields: #{problem_fields})" if problem_fields.present?
      end

      def reconstruct_includes(new_doc, klass)
        BASIC_METADATA_FIELDS.each { |unstored, stored| new_doc[unstored] = new_doc[stored] } if klass.ancestors.include? Hyrax::BasicMetadata
        CORE_METADATA_FIELDS.each { |unstored, stored| new_doc[unstored] = new_doc[stored] } if klass.ancestors.include? Hyrax::CoreMetadata
        HUMAN_READABLE_FIELDS.each { |unstored, stored| new_doc[unstored] = new_doc[stored] } if klass.ancestors.include? Hyrax::HumanReadableType
        # Deepblue::DefaultMetadata
        # Deepblue::FileSetMetadata
        # Umrdr::UmrdrWorkMetadata
        reconstruct_dynamic_fields(new_doc) # if klass.ancestors.include? AllinsonFlex::DynamicMetadataBehavior # FIXME
        new_doc
      end

      def reconstruct_class(new_doc, klass)
        class_metadata_fields = case klass.to_s
                                when AdminSet.to_s
                                  {
                                    # Hyrax::AdminSet
                                    "title_sim" => "title_tesim"
                                  }
                                when Collection.to_s
                                  {}
                                when FileSet.to_s
                                  {
                                    # Hyrax::FileSetIndexer
                                    "file_format_sim" => "file_format_tesim",
                                  }
                                else
                                  if klass.ancestors.include?(Hyrax::WorkBehavior)
                                    {
                                      # Hyrax::WorkIndexer
                                      "admin_set_sim" => "admin_set_tesim",
                                    }
                                  else
                                    {}
                                  end
                                end

        class_metadata_fields.each { |unstored, stored| new_doc[unstored] = new_doc[stored] }

        # generic_type_sim
        generic_type = case klass.to_s
                       when AdminSet.to_s
                         "Admin Set" # Hyrax::AdminSetIndexer
                       when Collection.to_s
                         "Collection" # Hyrax::CollectionIndexer
                       else
                         if klass.ancestors.include?(Hyrax::WorkBehavior)
                           "Work" # Hyrax::WorkIndexer
                         else
                           nil
                         end
                       end
        new_doc["generic_type_sim"] = [generic_type]

        new_doc
      end
    end

    class ReconstructedDocValidator
      def self.validate_reconstructed_solr_doc(reconstructed_doc)
        original_doc = ActiveFedora::Base.find(reconstructed_doc["id"]).to_solr.stringify_keys!.select {|k,v| v.present?}
        original_doc.map do |k,v|
          if k.end_with? "m"
            original_doc[k] = Array(v)
          elsif k =~ /_s[a-z]*$/
            original_doc[k] = v.to_s
          end
        end

        hash_diff = HashDiff::Comparison.new(original_doc, reconstructed_doc)
        missing_or_changed_fields = hash_diff.diff.select {|k,v| !(v[0].nil? || v[0] == HashDiff::NO_VALUE) }
        #missing_or_changed_fields.empty? ? true : false
      end
    end
  end
end

# Taken from HashDiff gem and modified to sort arrays given rdf is non-deterministic as to order of values
module HashDiff
  class NO_VALUE; end

  class Comparison
    def initialize(left, right)
      @left  = left
      @right = right
    end

    attr_reader :left, :right

    def diff
      @diff ||= find_differences { |l, r| [l, r] }
    end

    def left_diff
      @left_diff ||= find_differences { |_, r| r }
    end

    def right_diff
      @right_diff ||= find_differences { |l, _| l }
    end

    protected

    def find_differences(&reporter)
      combined_keys.each_with_object({ }, &comparison_strategy(reporter))
    end

    private

    def comparison_strategy(reporter)
      lambda do |key, diff|
        diff[key] = report_difference(key, reporter) unless equal?(key)
      end
    end

    def combined_keys
      if hash?(left) && hash?(right) then
        (left.keys + right.keys).uniq
      elsif array?(left) && array?(right) then
        (0..[left.size, right.size].max).to_a
      else
        raise ArgumentError, "Don't know how to extract keys. Neither arrays nor hashes given"
      end
    end

    def equal?(key)
      value_with_default(left, key) == value_with_default(right, key)
    end

    def hash?(value)
      value.is_a?(Hash)
    end

    def array?(value)
      value.is_a?(Array)
    end

    def comparable_hash?(key)
      hash?(left[key]) && hash?(right[key])
    end

    def comparable_array?(key)
      array?(left[key]) && array?(right[key])
    end

    def report_difference(key, reporter)
      if comparable_hash?(key)
        self.class.new(left[key], right[key]).find_differences(&reporter)
      elsif comparable_array?(key)
        self.class.new(left[key], right[key]).find_differences(&reporter)
      else
        reporter.call(
          value_with_default(left, key),
          value_with_default(right, key)
        )
      end
    end

    def value_with_default(obj, key)
      value = obj.fetch(key, NO_VALUE)
      value.sort if array?(value)
    end
  end
end
