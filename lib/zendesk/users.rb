require 'virtus'
require 'zendesk/user'

module Zendesk
  class Users
    include Virtus.model

    attribute :users, Array[Zendesk::User]
    attribute :next_page, String
    attribute :previous_page, String
    attribute :countdemail, Integer
  end
end
