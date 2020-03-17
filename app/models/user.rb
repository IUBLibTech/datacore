class User < ApplicationRecord
  # Connects this user object to Hydra behaviors.
  include Hydra::User
  # Connects this user object to Hyrax behaviors.
  include Hyrax::User
  include Hyrax::UserUsageStats

  if Rails.configuration.authentication_method == "umich"
    before_validation :generate_password, :on => :create

    def generate_password
      self.password = SecureRandom.urlsafe_base64(12)
      self.password_confirmation = self.password
    end
  end

  # Use the http header as auth.  This app will be behind a reverse proxy
  #   that will take care of the authentication.
  Devise.add_module(:http_header_authenticatable,
                    strategy: true,
                    controller: :sessions,
                    model: 'devise/models/http_header_authenticatable')
  if Rails.configuration.authentication_method == "umich"
    devise :http_header_authenticatable
  end

  if Rails.configuration.authentication_method == "iu"
    devise :omniauthable, :omniauth_providers => [:cas]
    alias_attribute :ldap_lookup_key, :uid
    include LDAPGroupsLookup::Behavior
  else
    devise :database_authenticatable, :registerable,
           :recoverable, :rememberable, :trackable, :validatable
  end
  if Blacklight::Utils.needs_attr_accessible?
    attr_accessible :email, :password, :password_confirmation
  end
  # Connects this user object to Blacklights Bookmarks.
  include Blacklight::User
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable

  # Method added by Blacklight; Blacklight uses #to_s on your
  # user class to get a user-displayable login/identifier for
  # the account.
  def to_s
    email
  end

  # helper for IU auth
  def self.find_for_iu_cas(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create! do |user|
      user.provider = auth.provider
      user.uid = auth.uid
      user.email = [auth.uid,'@iu.edu'].join
      user.encrypted_password = Devise.friendly_token[0,20]
    end
  end

  def groups
    (super << self.campus).compact
  end

  # Fetches a user's campus code and filters it through the app's active campuses
  def update_campus
    active_list = campus_service.new.active_ids
    ldap_list = ldap_campus
    user_campus = active_list.select { |c| c == ldap_list.first }
    self.campus = user_campus.first
    save!
  end

  def campus_service
    ::Datacore::CampusVisibilityService
  end

private

  # @return Array containing campus code string
  def ldap_campus
    result = LDAPGroupsLookup.service.search(base: LDAPGroupsLookup.tree, filter: Net::LDAP::Filter.equals('cn', ldap_lookup_key), attributes: 'ou').first&.ou
    Rails.logger.debug "#{LDAPGroupsLookup.service.host} reports campus for #{ldap_lookup_key} is #{result}"
    result
  end

end
