# frozen_string_literal: true

module Datacore

  class DoiMintingService

    PUBLISHER = "Indiana University".freeze
    RESOURCE_TYPE = "Dataset".freeze

    attr_reader :current_user, :work, :metadata, :prefix, :doi

    # @return Boolean
    def self.enabled?
      Settings.datacite.enabled
    end
    delegate :enabled?, to: :class

    # @param work [DataSet] Dataset getting the DOI minted
    # @param current_user [String] email for user requesting minting
    # @return [String, nil] returns DOI on successful minting, nil on failure or error
    def self.mint_doi_for(work:, current_user:)
      Datacore::DoiMintingService.new(work: work, current_user: current_user).run if enabled?
    end

    # @return [nil]
    # logs failure, updates work DOI nil
    def failed_minting!
      Rails.logger.error "DoiMintingService failure for: work: #{work.id}, user: #{current_user}, nullifying doi value"
      update_work_with_doi!(nil)
    end

    def initialize(work:, current_user:)
      @work = work
      @current_user = current_user
      @metadata = local_metadata
      @prefix = Settings.datacite.prefix
      @doi = work.doi
    end

    # @return [String, nil] DOI on successful minting, nil on failure or error 
    def run
      return unless enabled?
      if work.valid? && work.doi_pending?
        doi = mint_doi!
        if doi
          update_work_with_doi!(doi, update_provenance: true)
        else
          failed_minting!
        end
      else
        Rails.logger.error "DoiMintingService called for work (#{work.id}) with invalid state (#{!work.valid?}) or doi value (#{work.doi})"
        false
      end
    end

    private
      # @return [String, nil] work's DOI
      # updates work DOI
      # conditionally logs minting to provenance
      def update_work_with_doi!(doi, update_provenance: false)
        work.reload # consider locking work
        if work.doi == doi
          @doi = doi
        else
          work.doi = doi
          work.save
          work.reload
          work.provenance_mint_doi(current_user: current_user, event_note: 'DoiMintingService') if update_provenance
          @doi = work.doi
        end
        @doi
      end

      # @return [Hash] work minimal metadata for remote record creation or update
      def local_metadata
        { creators: work.creator.map { |c| { name: c } },
          titles: work.title.map { |t| { title: t } },
          publisher: PUBLISHER,
          publicationYear: Date.today.year.to_s,
          types: { resourceTypeGeneral: RESOURCE_TYPE },
          url: Rails.application.routes.url_helpers.hyrax_data_set_url(id: work.id)
        }
      end

      # @return [DataCite::Client] client instance for Datacite interactions
      def client(host: Settings.datacite.host, username: Settings.datacite.username, password: Settings.datacite.password)
        @client ||= Datacite::Client.new(host: host, username: username, password: password)
      end

      # client interaction methods below

      # @return [String, nil] DOI value on successful minting, nil on failure or error
      def mint_doi!(suffix: nil)
        begin
          if suffix.present?
            result = client.register_doi(prefix: prefix, suffix: suffix, metadata: metadata)
          else
            result = client.autogenerate_doi(prefix: prefix, metadata: metadata)
          end
          result.success? ? result.value!.doi : nil
        rescue => e
          Rails.logger.error("Error in DoiMintingService#mint_doi!: #{e.inspect}")
          nil
        end
      end

      # developer client methods below, not currently called

      # @return [Boolean, nil] true if DOI found remotely, false if not, nil on failure or error
      def doi_exists?
        return unless work.doi_minted?
        begin
          result = client.exists?(id: work.doi)
          result.success? ? result.value! : nil
        rescue => e
          Rails.logger.error("Error in DoiMintingService#doi_exists?: #{e.inspect}")
          nil
        end
      end

      # @return [Hash, nil] remote metadata Hash if found for DOI, nil on failure or error
      def doi_metadata
        return nil unless doi_exists?
        begin
          result = client.metadata(id: work.doi)
          result.success? ? result.value! : nil
        rescue => e
          Rails.logger.error("Error in DoiMintingService#doi_metadata: #{e.inspect}")
          nil
        end
      end

      # @return [String] remote metadata XML if found for DOI, blank string for failure or error
      def doi_xml
        begin
          Base64.decode64(doi_metadata&.dig('data', 'attributes', 'xml')&.to_s)
        rescue => e
          Rails.logger.error("Error in DoiMintingService#doi_xml: #{e.inspect}")
          nil
        end
      end

      # @return [String, nil] returns DOI on successul remote metadata update, nil on failure or error
      def update_metadata!
        return nil unless doi_exists?
        begin
          result = client.update(id: doi, metadata: metadata)
          result.success? ? result.value!.doi : nil
        rescue => e
          Rails.logger.error("Error in DoiMintingService#update_metadata!: #{e.inspect}")
          nil
        end
      end
  end
end
