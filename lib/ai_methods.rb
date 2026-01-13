require "dotenv/load"
require_relative "ai_methods/version"
require_relative "ai_methods/configuration"
require_relative "ai_methods/cache"
require_relative "ai_methods/context_builder"
require_relative "ai_methods/client"
require_relative "ai_methods/executor"

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

  # Hook called when this module is included in a class
  def self.included(base)
    # Store reference to including class if needed
  end

  # Intercept calls to undefined methods
  def method_missing(method_name, *args, &block)
    cache = AIMethods::Cache.new
    class_name = self.class.name

    # 1. Check cache first
    cached_code = cache.find(class_name, method_name.to_s)
    if cached_code
      cache.touch(class_name, method_name.to_s)
      return execute_generated_code(cached_code, args, &block)
    end

    # 2. Build context and call Claude
    context_builder = AIMethods::ContextBuilder.new(cache)
    context = context_builder.build(self.class)

    client = AIMethods::Client.new
    generated_code = client.generate_code(
      method_name.to_s,
      args,
      context: context,
      block_given: block_given?
    )

    # 3. Store in cache
    signature = args.map(&:class).join(',')
    cache.store(class_name, method_name.to_s, signature, generated_code)

    # 4. Execute and return
    execute_generated_code(generated_code, args, &block)
  end

  # Respond to any method call (AI can handle any method)
  def respond_to_missing?(method_name, include_private = false)
    true
  end

  private

  # Execute generated code in instance context
  def execute_generated_code(code, args, &block)
    executor = AIMethods::Executor.new
    # Execute in instance context so generated code can access self, instance vars, other methods
    executor.execute(code, binding)
  end
end

