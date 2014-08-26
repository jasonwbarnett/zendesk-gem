require 'virtus'

module Zendesk
  class Identity
    include Virtus.model

    attribute :id, Integer
    attribute :url, String
    attribute :user_id, Integer
    attribute :type, String
    attribute :value, String
    attribute :verified, Boolean
    attribute :primary, Boolean
    attribute :created_at, DateTime
    attribute :updated_at, DateTime
  end
end
