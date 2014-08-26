require 'virtus'
require 'zendesk/attachment'
require 'zendesk/identity'

module Zendesk
  class User
    include Virtus.model

    attribute :id, Integer
    attribute :url, String
    attribute :name, String
    attribute :email, String
    attribute :created_at, DateTime
    attribute :updated_at, DateTime
    attribute :time_zone, String
    attribute :phone, String
    attribute :photo, Zendesk::Attachment
    attribute :locale_id, Integer
    attribute :locale, String
    attribute :organization_id, Integer
    attribute :role, String
    attribute :verified, Boolean
    attribute :external_id, String
    attribute :tags, Array
    attribute :alias, String
    attribute :active, Boolean
    attribute :shared, Boolean
    attribute :shared_agent, Boolean
    attribute :last_login_at, DateTime
    attribute :signature, String
    attribute :details, String
    attribute :notes, String
    attribute :custom_role_id, Integer
    attribute :moderator, Boolean
    attribute :ticket_restriction, String
    attribute :only_private_comments, Boolean
    attribute :restricted_agent, Boolean
    attribute :suspended, Boolean
    attribute :user_fields, Hash

    attribute :identities, Array[Zendesk::Identity]

  end
end
