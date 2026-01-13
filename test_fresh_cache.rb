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
$api_calls = 0

# Mock the AIMethods Client to track API calls
module AIMethods
  class Client
    def initialize
      # Mock initialization - do nothing
    end
    
    def generate_code(method_name, args, context: nil, block_given: false)
      $api_calls += 1
      puts "  [API CALL ##{$api_calls}] Generating code for #{method_name}(#{args.inspect})"
      
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

class TestCalculator
  include AIMethods
end

puts "=" * 60
puts "Fresh Cache Test (In-Memory)"
puts "=" * 60
puts ""

calc = TestCalculator.new

puts "Test 1: Call fibonacci(10) - should trigger API call"
result1 = calc.fibonacci(10)
puts "Result: #{result1}, API calls: #{$api_calls}"
puts ""

puts "Test 2: Call fibonacci(10) again - should use cache"
result2 = calc.fibonacci(10)
puts "Result: #{result2}, API calls: #{$api_calls}"
puts ""

puts "Test 3: Call factorial(5) - should trigger API call"
result3 = calc.factorial(5)
puts "Result: #{result3}, API calls: #{$api_calls}"
puts ""

puts "Test 4: Call factorial(5) again - should use cache"
result4 = calc.factorial(5)
puts "Result: #{result4}, API calls: #{$api_calls}"
puts ""

puts "=" * 60
if $api_calls == 2
  puts "✓ SUCCESS: Cache working! 2 API calls for 4 invocations"
else
  puts "✗ ISSUE: Expected 2 API calls, got #{$api_calls}"
end
puts "=" * 60

