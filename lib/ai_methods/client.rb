require 'anthropic'

module AIMethods
  class Client
    # Initialize the Claude API client
    # @param config [Configuration] The configuration object (defaults to AIMethods.configuration)
    def initialize(config = nil)
      @config = config || AIMethods.configuration
      @client = Anthropic::Client.new(api_key: @config.api_key)
    end

    # Generate code for a method using Claude
    # @param method_name [String] The name of the method to generate
    # @param args [Array] The arguments passed to the method
    # @param context [String] The context string from ContextBuilder
    # @param block_given [Boolean] Whether a block was passed
    # @return [String] The generated Ruby code
    def generate_code(method_name, args, context:, block_given:)
      prompt = build_prompt(method_name, args, context, block_given)

      response = @client.messages.create(
        model: @config.model,
        max_tokens: @config.max_tokens,
        messages: [
          { role: "user", content: prompt }
        ]
      )

      extract_code(response)
    rescue StandardError => e
      raise "Failed to generate code: #{e.message}"
    end

    private

    # Build the prompt for Claude
    # @param method_name [String] The method name
    # @param args [Array] The arguments
    # @param context [String] The context string
    # @param block_given [Boolean] Whether a block was given
    # @return [String] The formatted prompt
    def build_prompt(method_name, args, context, block_given)
      arg_types = args.map(&:class).map(&:to_s).join(", ")
      
      <<~PROMPT
        You are a Ruby code generator. Given a method call, generate ONLY the Ruby code 
        to implement it. Return executable Ruby code that produces the expected result.

        Method called: #{method_name}
        Arguments: #{args.inspect}
        Argument types: #{arg_types}
        Block given: #{block_given}

        #{context}

        You may call any of the above methods in your implementation if useful.
        Respond with ONLY valid Ruby code, no markdown, no explanation.
        The code should return/compute the result directly.
      PROMPT
    end

    # Extract the code from Claude's response
    # @param response [Anthropic::Models::Message] The API response
    # @return [String] The extracted code
    def extract_code(response)
      # The anthropic gem returns objects, not hashes
      content = response.content&.first&.text

      if content.nil? || content.empty?
        raise "Claude returned empty response"
      end

      # Remove markdown code blocks if present
      code = content.strip
      code = code.sub(/^```ruby\n/, '').sub(/\n```$/, '') if code.start_with?('```')
      code = code.sub(/^```\n/, '').sub(/\n```$/, '') if code.start_with?('```')

      code.strip
    end
  end
end

