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

# Mock the AIMethods Client to avoid needing an API key
module AIMethods
  class Client
    def initialize
      # Mock initialization - do nothing
    end

    def generate_code(method_name, args, context: nil, block_given: false)
      # Return mock implementations for testing
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
      when 'sum'
        <<~RUBY
          def sum(*numbers)
            numbers.reduce(0, :+)
          end
          sum(#{args.join(', ')})
        RUBY
      else
        "# Generated method: #{method_name}\n#{args.inspect}"
      end
    end
  end
end

class Calculator
  include AIMethods
end

puts "=" * 60
puts "Testing AIMethods Integration"
puts "=" * 60
puts ""

calc = Calculator.new

# Test 1: fibonacci
puts "Test 1: fibonacci(10)"
puts "-" * 40
result = calc.fibonacci(10)
puts "Result: #{result}"
puts "Expected: 55"
puts "✓ PASS" if result == 55
puts ""

# Test 2: fibonacci again (should use cache)
puts "Test 2: fibonacci(10) again (cached)"
puts "-" * 40
result2 = calc.fibonacci(10)
puts "Result: #{result2}"
puts "Expected: 55"
puts "✓ PASS" if result2 == 55
puts ""

# Test 3: factorial
puts "Test 3: factorial(5)"
puts "-" * 40
result3 = calc.factorial(5)
puts "Result: #{result3}"
puts "Expected: 120"
puts "✓ PASS" if result3 == 120
puts ""

# Test 4: sum
puts "Test 4: sum(1, 2, 3, 4, 5)"
puts "-" * 40
result4 = calc.sum(1, 2, 3, 4, 5)
puts "Result: #{result4}"
puts "Expected: 15"
puts "✓ PASS" if result4 == 15
puts ""

puts "=" * 60
puts "All tests completed!"
puts "=" * 60

