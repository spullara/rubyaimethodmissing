require "dotenv/load"
require_relative "ai_methods/version"
require_relative "ai_methods/configuration"
require_relative "ai_methods/cache"
require_relative "ai_methods/context_builder"
require_relative "ai_methods/client"

module AIMethods
  class << self
    attr_accessor :configuration

    def configure
      self.configuration ||= Configuration.new
      yield(configuration) if block_given?
      configuration
    end
  end

  self.configuration = Configuration.new
end

