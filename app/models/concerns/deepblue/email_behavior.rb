# frozen_string_literal: true

module Deepblue

  require_relative './abstract_event_behavior'

  class EmailError < AbstractEventError
  end

  module EmailBehavior
    include AbstractEventBehavior

    def attributes_all_for_email
      %i[]
    end

    def attributes_brief_for_email
      %i[]
    end

    def attributes_for_email_create
      attributes_all_for_email
    end

    def email_attribute_values_for_snapshot( attributes:,
                                             current_user:,
                                             event:,
                                             event_note:,
                                             ignore_blank_key_values:,
                                             **added_email_key_values )

      email_key_values = { user_email: for_email_user( current_user ) }
      email_key_values.merge!( event_note: event_note ) if event_note.present?
      email_key_values.merge!( added_email_key_values ) if added_email_key_values.present?
      email_key_values = map_email_attributes!( event: event,
                                                attributes: attributes,
                                                ignore_blank_key_values: ignore_blank_key_values,
                                                **email_key_values )
      email_key_values
    end

    def email_address_rds
      rv = EmailHelper.notification_email # will be nil on developer's machine
      rv
    end

    def email_address_user( current_user )
      rv = EmailHelper.user_email_from current_user
      rv
    end

    def email_compose_body( event_note:, email_key_values: )
      body = StringIO.new
      body.puts event_note.to_s if event_note.present?
      email_key_values.each_pair do |key, value|
        label = for_email_label key
        value = for_email_value( key, value )
        body.puts "#{label}#{value}"
      end
      body.string
    end

    def email_create( to:, current_user:, event_note: '' )
      email_event_notification( to: to,
                                from: email_address_rds,
                                subject: for_email_subject(subject_rest: 'New Work Created' ),
                                attributes: attributes_for_email_create,
                                current_user: current_user,
                                event: EVENT_CREATE,
                                event_note: event_note,
                                id: for_email_id,
                                ignore_blank_key_values: false )
    end

    def email_create_to_rds( current_user:, event_note: '' )
      email_create( to: email_address_rds, current_user: current_user, event_note: event_note )
    end

    def email_create_to_user( current_user:, event_note: '' )
      email_create( to: email_address_user( current_user ), current_user: current_user, event_note: event_note )
    end

    def for_email_class
      for_email_object.class
    end

    def for_email_id
      for_email_object.id
    end

    def for_email_ignore_empty_attributes
      true
    end

    def for_email_label( key )
      "#{key}: "
    end

    def for_email_object
      self
    end

    def for_email_route
      "route to #{for_email_object.id}"
    end

    def for_email_subject( subject_rest: )
      "DBD: #{subject_rest}"
    end

    def for_email_value( key, value )
      return '' if value.blank?
      if value.respond_to? :each
        value = if 1 == value.size
                  value[0]
                else
                  value.join( for_email_value_sep( key: key ) )
                end
      end
      value
    end

    def for_email_value_sep( key: )
      rv = case key.to_s
           when 'title'
             ' '
           else
             '; '
           end
      rv
    end

    def for_email_user( current_user )
      return '' if current_user.blank?
      return current_user if current_user.is_a? String
      EmailHelper.user_email_from( current_user )
    end

    def map_email_attributes!( event:, attributes:, ignore_blank_key_values:, **email_key_values )
      prov_object = for_email_object
      if attributes.present?
        attributes.each do |attribute|
          next if map_email_attributes_override!( event: event,
                                                  attribute: attribute,
                                                  ignore_blank_key_values: ignore_blank_key_values,
                                                  email_key_values: email_key_values )
          value = case attribute.to_s
                  when 'id'
                    for_email_id
                  when 'location'
                    for_email_route
                  when 'route'
                    for_email_route
                  when 'date_created'
                    prov_object[:date_created].blank? ? '' : prov_object[:date_created][0]
                  else
                    prov_object[attribute]
                  end
          value = '' if value.nil?
          if ignore_blank_key_values
            email_key_values[attribute] = value if value.present?
          else
            email_key_values[attribute] = value
          end
        end
      end
      email_key_values
    end

    # override this if there is anything extra to add
    # return true if handled
    def map_email_attributes_override!( event:,                    # rubocop:disable Lint/UnusedMethodArgument
                                        attribute:,                # rubocop:disable Lint/UnusedMethodArgument
                                        ignore_blank_key_values:,  # rubocop:disable Lint/UnusedMethodArgument
                                        email_key_values: )        # rubocop:disable Lint/UnusedMethodArgument

      handled = false
      return handled
    end

    protected

      def email_event_notification( to:,
                                    from:,
                                    subject:,
                                    attributes:,
                                    current_user:,
                                    event:,
                                    event_note:,
                                    ignore_blank_key_values:,
                                    id:,
                                    email_key_values: nil )

        if email_key_values.blank?
          email_key_values = email_attribute_values_for_snapshot( attributes: attributes,
                                                                  current_user: current_user,
                                                                  event: event,
                                                                  event_note: event_note,
                                                                  ignore_blank_key_values: ignore_blank_key_values )
        end
        event_attributes_cache_write( event: event, id: id, behavior: :EmailBehavior )
        body = email_compose_body( event_note: event_note, email_key_values: email_key_values )
        # TODO: write to log
        # ApplicationMailer.mail( to: to, from: from, subject: subject, body: body )
        Rails.logger.debug ">>>>>>"
        Rails.logger.debug "email_event_notification"
        Rails.logger.debug "to: #{to}\nfrom: #{from}\nsubject: #{subject}\nbody:\n#{body}"
        Rails.logger.debug ">>>>>>"
      end

  end

end