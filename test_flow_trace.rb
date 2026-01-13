#!/usr/bin/env ruby

# Mock the Anthropic client BEFORE loading ai_methods
module Anthropic
  class Client
    def initialize(*args, **kwargs)
      # Mock initialization - do nothing
    end
    
    def messages(*args, **kwargs)
      # Mock response
      OpenStruct.new(content: [OpenStruct.new(text: "mocked")])
    end
  end
end

require_relative 'lib/ai_methods'

# Track calls
$cache_hits = 0
$cache_misses = 0
$api_calls = 0

# Patch the Cache to track hits/misses
module AIMethods
  class Cache
    alias_method :original_find, :find

    def find(class_name, method_name, method_signature)
      result = original_find(class_name, method_name, method_signature)
      if result
        $cache_hits += 1
        puts "  [CACHE HIT] #{class_name}##{method_name}(#{method_signature})"
      else
        $cache_misses += 1
        puts "  [CACHE MISS] #{class_name}##{method_name}(#{method_signature})"
      end
      result
    end
  end
  
  class Client
    def initialize
      # Mock initialization - do nothing
    end
    
    def generate_code(method_name, args, context: nil, block_given: false)
      $api_calls += 1
      puts "  [API CALL ##{$api_calls}] Generating code for #{method_name}"
      
      case method_name
      when 'fibonacci'
        <<~RUBY
          def fibonacci(n)
            return n if n <= 1
            fibonacci(n - 1) + fibonacci(n - 2)
          end
          fibonacci(#{args[0]})
        RUBY
      when 'factorial'
        <<~RUBY
          def factorial(n)
            return 1 if n <= 1
            n * factorial(n - 1)
          end
          factorial(#{args[0]})
        RUBY
      else
        "# Generated method: #{method_name}"
      end
    end
  end
end

class Calculator
  include AIMethods
end

puts "=" * 60
puts "Flow Trace Test"
puts "=" * 60
puts ""

calc = Calculator.new

puts "Test 1: Call fibonacci(10)"
result1 = calc.fibonacci(10)
puts "Result: #{result1}"
puts ""

puts "Test 2: Call fibonacci(10) again"
result2 = calc.fibonacci(10)
puts "Result: #{result2}"
puts ""

puts "=" * 60
puts "Summary:"
puts "  Cache Hits: #{$cache_hits}"
puts "  Cache Misses: #{$cache_misses}"
puts "  API Calls: #{$api_calls}"
puts "=" * 60

