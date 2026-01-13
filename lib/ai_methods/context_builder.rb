module AIMethods
  class ContextBuilder
    # Initialize with a cache reference
    # @param cache [Cache] The cache instance for querying generated methods
    def initialize(cache)
      @cache = cache
    end

    # Build full context string for a class
    # @param klass [Class] The class to build context for
    # @return [String] Formatted context string
    def build(klass)
      existing = format_existing_methods(klass)
      generated = format_generated_methods(klass.name)

      <<~CONTEXT
        ## Existing methods in this class:
        #{existing}

        ## Previously generated methods for this class:
        #{generated}
      CONTEXT
    end

    # Format existing methods defined on the class
    # @param klass [Class] The class to extract methods from
    # @return [String] Formatted methods string
    def format_existing_methods(klass)
      methods = klass.instance_methods(false)
      
      if methods.empty?
        return "(none)"
      end

      methods.map do |method_name|
        method = klass.instance_method(method_name)
        source = try_get_source(method)
        
        if source
          "def #{method_name}\n#{source}\nend"
        else
          format_method_signature(method_name, method)
        end
      end.join("\n\n")
    end

    # Format previously generated methods from cache
    # @param class_name [String] The name of the class
    # @return [String] Formatted generated methods string
    def format_generated_methods(class_name)
      cached_methods = @cache.find_all_for_class(class_name)
      
      if cached_methods.empty?
        return "(none)"
      end

      cached_methods.map do |method_hash|
        method_name = method_hash[:method_name]
        code = method_hash[:generated_code]
        "def #{method_name}\n#{code}\nend"
      end.join("\n\n")
    end

    private

    # Try to get source code of a method using method_source gem
    # @param method [UnboundMethod] The method to get source for
    # @return [String, nil] Source code or nil if unavailable
    def try_get_source(method)
      begin
        require 'method_source'
        method.source
      rescue LoadError, MethodSource::SourceNotAvailableError
        nil
      end
    end

    # Format method signature when source is not available
    # @param method_name [Symbol] The method name
    # @param method [UnboundMethod] The method object
    # @return [String] Formatted signature
    def format_method_signature(method_name, method)
      arity = method.arity
      parameters = method.parameters
      
      if parameters.empty?
        "def #{method_name}; end"
      else
        param_str = parameters.map { |type, name| name.to_s }.join(", ")
        "def #{method_name}(#{param_str}); end"
      end
    end
  end
end

