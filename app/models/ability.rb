# frozen_string_literal: true

class Ability
  include Hydra::Ability
  include Hyrax::Ability

  # self.ability_logic += [:everyone_can_create_curation_concerns]
  self.ability_logic += [:deepblue_abilities]

  def deepblue_abilities
    alias_action :display_provenance_log,    to: :read
    alias_action :globus_clean_download,     to: :delete
    alias_action :globus_download,           to: :read
    alias_action :globus_add_email,          to: :read
    alias_action :globus_download_add_email, to: :read
    alias_action :globus_download_notify_me, to: :read
    alias_action :tombstone,                 to: :delete
    alias_action :zip_download,              to: :read

    # alias_action :confirm,                   to: :read
    # alias_action :identifiers,               to: :update
  end

  # Define any customized permissions here.
  def custom_permissions
    # Limits deleting objects to a the admin user
    #
    # if current_user.admin?
    #   can [:destroy], ActiveFedora::Base
    # end

    # Limits creating new objects to a specific group
    #
    # if user_groups.include? 'special_group'
    #   can [:create], ActiveFedora::Base
    # end

    # restrict depositing permissions
    if can_deposit?
      can [:create], DataSet
      can [:doi], DataSet
      can [:create], FileSet
    else
      cannot [:create, :edit, :update, :destroy], DataSet
      cannot [:create, :edit, :update, :destroy], FileSet
    end
    if admin?
      # can [:create, :show, :add_user, :remove_user, :index, :edit, :update, :destroy], Role  # uncomment to expose Role management in UI
    end 
  end

  def can_deposit?
    admin? || depositor?
  end

  def admin?
    current_user.admin? || super
  end

  def depositor?
    depositing_role = Sipity::Role.find_by(name: Hyrax::RoleRegistry::DEPOSITING)
    return false unless depositing_role
    Hyrax::Workflow::PermissionQuery.scope_processing_agents_for(user: current_user).any? do |agent|
      agent.workflow_responsibilities.joins(:workflow_role)
           .where('sipity_workflow_roles.role_id' => depositing_role.id).any?
    end
  end
end
