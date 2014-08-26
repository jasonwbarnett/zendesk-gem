require 'virtus'
require 'zendesk/user'

module Zendesk
  class Search
    include Virtus.model

    attribute :results, Array
    attribute :next_page, String
    attribute :previous_page, String
    attribute :count, Integer
  end
end
