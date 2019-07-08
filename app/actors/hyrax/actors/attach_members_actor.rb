module Hyrax
  module Actors
    # Attach or remove child works to/from this work. This decodes parameters
    # that follow the rails nested parameters conventions:
    # e.g.
    #   'work_members_attributes' => {
    #     '0' => { 'id' => '12312412'},
    #     '1' => { 'id' => '99981228', '_destroy' => 'true' }
    #   }
    #
    # The goal of this actor is to mutate the ordered_members with as few writes
    # as possible, because changing ordered_members is slow. This class only
    # writes changes, not the full ordered list.
    class AttachMembersActor < Hyrax::Actors::AbstractActor
      # @param [Hyrax::Actors::Environment] env
      # @return [Boolean] true if update was successful
      def update(env)
        # log_event( env: env )
        attributes_collection = env.attributes.delete(:work_members_attributes)
        ::Deepblue::LoggingHelper.bold_debug "AttachMembersActor.update: next_actor = #{next_actor.class.name}"
        assign_nested_attributes_for_collection(env, attributes_collection) &&
          next_actor.update(env)
      end

      private

        # Attaches any unattached members.  Deletes those that are marked _delete
        # @param [Hash<Hash>] a collection of members
        def assign_nested_attributes_for_collection(env, attributes_collection)
          return true unless attributes_collection
          attributes_collection = attributes_collection.sort_by { |i, _| i.to_i }.map { |_, attributes| attributes }
          # checking for existing works to avoid rewriting/loading works that are
          # already attached
          existing_works = env.curation_concern.member_ids
          attributes_collection.each do |attributes|
            next if attributes['id'].blank?
            if existing_works.include?(attributes['id'])
              remove(env.curation_concern, attributes['id']) if has_destroy_flag?(attributes)
            else
              add(env, attributes['id'])
            end
          end
        end

        # Adds the item to the ordered members so that it displays in the items
        # along side the FileSets on the show page
        def add2(env, id)
          member = ActiveFedora::Base.find(id)
          return unless env.current_ability.can?(:edit, member)
          env.curation_concern.ordered_members << member
        end

        # Remove the object from the members set and the ordered members list
        def remove2(curation_concern, id)
          member = ActiveFedora::Base.find(id)
          curation_concern.ordered_members.delete(member)
          curation_concern.members.delete(member)
        end

        def add( env, id )
          # ::Deepblue::LoggingHelper.bold_debug "AttachMembersActor.add: id = #{id}"
          return if id.blank?
          member = ActiveFedora::Base.find( id )
          # is this check necessary?
          can_do_it = env.current_ability.can?( :edit, member )
          # ::Deepblue::LoggingHelper.bold_debug "AttachMembersActor.add: id = #{id} can_do_it = #{can_do_it}"
          return unless can_do_it
          # ::Deepblue::LoggingHelper.bold_debug "AttachMembersActor.add: adding ordered member id = #{id}"
          env.curation_concern.ordered_members << member

          return unless env.curation_concern.respond_to? :provenance_child_add
          current_user = env.user
          env.curation_concern.provenance_child_add( current_user: current_user,
                                                     child_id: id,
                                                     event_note: "AttachMembersActor" )
        end

          # Remove the object from the members set and the ordered members list
        def remove( curation_concern, id )
          # ::Deepblue::LoggingHelper.bold_debug "AttachMembersActor.remove: id = #{id}"
          return if id.blank?
          member = ActiveFedora::Base.find(id)
          curation_concern.ordered_members.delete(member)
          curation_concern.members.delete(member)
          return unless curation_concern.respond_to? :provenance_child_remove
          curation_concern.provenance_child_remove( current_user: current_user,
                                                    child_id: id,
                                                    event_note: "AttachMembersActor" )
        end

        # Determines if a hash contains a truthy _destroy key.
        # rubocop:disable Naming/PredicateName
        def has_destroy_flag?(hash)
          ActiveFedora::Type::Boolean.new.cast(hash['_destroy'])
        end
      # rubocop:enable Naming/PredicateName
    end
  end
end
