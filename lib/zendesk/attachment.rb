require 'virtus'
require 'zendesk/thumbnail'

module Zendesk
  class Attachment
    include Virtus.model

    attribute :id, Integer
    attribute :file_name, String
    attribute :content_url, String
    attribute :content_type, String
    attribute :size, Integer
    attribute :thumbnails, Array[Zendesk::Thumbnail]
  end
end
