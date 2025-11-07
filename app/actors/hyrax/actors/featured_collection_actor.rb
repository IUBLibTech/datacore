
module Hyrax
  module Actors
    # Removes featured collections if the collection is deleted or becomes private
    class FeaturedCollectionActor < Hyrax::Actors::AbstractActor
      # @return [Boolean] true if destroy was successful
      def destroy(env)
        cleanup_featured_collections(env.curation_concern)
        next_actor.destroy(env)
      end

      # @param [Hyrax::Actors::Environment] env
      # @return [Boolean] true if update was successful
      def update(env)
        check_featureability(env.curation_concern)
        next_actor.update(env)
      end

      private

      def cleanup_featured_collections(curation_concern)
        FeaturedCollection.where(collection_id: curation_concern.id).destroy_all
      end

      def check_featureability(curation_concern)
        return unless curation_concern.private?
        cleanup_featured_collections(curation_concern)
      end
    end
  end
end
