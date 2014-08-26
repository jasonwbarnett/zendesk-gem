require "zendesk/version"
require "yaml"

module Zendesk
  CONFIG_PATH = File.expand_path("~/.zendesk2")

  def self.config
    @config ||= load_config
  end

  def self.load_config
    File.exists?(Zendesk::CONFIG_PATH) ? YAML.load_file(Zendesk::CONFIG_PATH) : {}
  end
end
