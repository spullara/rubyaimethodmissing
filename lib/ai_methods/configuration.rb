module AIMethods
  class Configuration
    attr_accessor :api_key, :model, :db_path, :max_tokens, :max_retries

    def initialize
      @api_key = ENV["ANTHROPIC_API_KEY"]
      @model = "claude-opus-4-20250514"
      @db_path = File.expand_path("~/.ai_methods/cache.db")
      @max_tokens = 4096
      @max_retries = 2
    end
  end
end

