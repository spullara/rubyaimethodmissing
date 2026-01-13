module AIMethods
  class Executor
    # Initialize the executor
    def initialize
      # No special initialization needed for now
    end

    # Execute code in the given binding context
    # @param code [String] The Ruby code to execute
    # @param binding_context [Binding] The binding context to execute in
    # @return [Object] The result of executing the code
    # @raise [SyntaxError] If the code has invalid syntax
    # @raise [RuntimeError] If execution fails
    def execute(code, binding_context)
      # Strip markdown wrappers if present
      clean_code = strip_markdown(code)
      
      # Validate syntax before executing
      validate(clean_code)
      
      # Execute the code in the given binding context
      begin
        eval(clean_code, binding_context)
      rescue SyntaxError => e
        raise SyntaxError, "Generated code has invalid syntax: #{e.message}"
      rescue StandardError => e
        raise RuntimeError, "Generated code execution failed: #{e.message}"
      end
    end

    # Validate that code has valid Ruby syntax
    # @param code [String] The Ruby code to validate
    # @return [Boolean] True if valid
    # @raise [SyntaxError] If syntax is invalid
    def validate(code)
      begin
        RubyVM::InstructionSequence.compile(code)
        true
      rescue SyntaxError => e
        raise SyntaxError, "Generated code has invalid syntax: #{e.message}"
      end
    end

    # Strip markdown code fences from code if present
    # @param code [String] The code that may contain markdown wrappers
    # @return [String] The code without markdown wrappers
    def strip_markdown(code)
      clean = code.strip
      
      # Remove ```ruby ... ``` wrappers
      if clean.start_with?('```ruby')
        clean = clean.sub(/^```ruby\n?/, '').sub(/\n?```$/, '')
      # Remove ``` ... ``` wrappers (generic)
      elsif clean.start_with?('```')
        clean = clean.sub(/^```\n?/, '').sub(/\n?```$/, '')
      end
      
      clean.strip
    end
  end
end

