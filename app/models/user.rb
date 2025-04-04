class User < ApplicationRecord
  # Connects this user object to Hydra behaviors.
  include Hydra::User
  # Connects this user object to Role-management behaviors.
  include Hydra::RoleManagement::UserRoles
  # Connects this user object to Hyrax behaviors.
  include Hyrax::User
  include Hyrax::UserUsageStats

  # Use the http header as auth.  This app will be behind a reverse proxy
  #   that will take care of the authentication.
  Devise.add_module(:http_header_authenticatable,
                    strategy: true,
                    controller: :sessions,
                    model: 'devise/models/http_header_authenticatable')

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

end
