require 'virtus'

module Zendesk
  class Thumbnail
    include Virtus.model

    attribute :id, Integer
    attribute :file_name, String
    attribute :content_url, String
    attribute :content_type, String
    attribute :size, Integer
  end
end
