require "cgi"
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
    signature = args.map(&:class).join(',')

    # 3. Generate code with retry logic on execution failure
    generated_code = generate_code_with_retry(
      client,
      method_name.to_s,
      args,
      context,
      block_given?,
      max_retries: AIMethods.configuration.max_retries
    )

    # 4. Store in cache ONLY after successful execution
    cache.store(class_name, method_name.to_s, signature, generated_code)

    # 5. Execute and return
    execute_generated_code(generated_code, args, &block)
  end

  # Respond to any method call (AI can handle any method)
  def respond_to_missing?(method_name, include_private = false)
    true
  end

  private

  # Generate code with retry logic on execution failure
  # @param client [Client] The Claude API client
  # @param method_name [String] The method name
  # @param args [Array] The arguments
  # @param context [String] The context string
  # @param block_given [Boolean] Whether a block was given
  # @param max_retries [Integer] Maximum number of retries
  # @return [String] The generated code
  def generate_code_with_retry(client, method_name, args, context, block_given, max_retries: 2)
    generated_code = client.generate_code(
      method_name,
      args,
      context: context,
      block_given: block_given
    )

    # Try to execute the code to validate it works before caching
    begin
      executor = AIMethods::Executor.new
      executor.execute(generated_code, binding)
      # If execution succeeds, return the code
      return generated_code
    rescue Interrupt, SignalException, SystemExit
      # Propagate immediately - don't retry these
      raise
    rescue StandardError => e
      # Retry with error context
      if max_retries > 0
        puts "[AIMethods] Code execution failed: #{e.class}: #{e.message}"
        puts "[AIMethods] Retrying with error context (#{max_retries} retries left)..."

        fixed_code = client.fix_code(
          method_name,
          args,
          context: context,
          block_given: block_given,
          original_code: generated_code,
          error_class: e.class.to_s,
          error_message: e.message
        )

        # Recursively retry with the fixed code
        return generate_code_with_retry(
          client,
          method_name,
          args,
          context,
          block_given,
          max_retries: max_retries - 1
        )
      else
        # Out of retries, raise the error
        raise
      end
    end
  end

  # Execute generated code in instance context
  def execute_generated_code(code, args, &block)
    executor = AIMethods::Executor.new
    # Execute in instance context so generated code can access self, instance vars, other methods
    executor.execute(code, binding)
  end
end

