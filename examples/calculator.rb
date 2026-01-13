#!/usr/bin/env ruby

require_relative '../lib/ai_methods'

class Calculator
  include AIMethods
end

# Create a calculator instance
calc = Calculator.new

# Call fibonacci - this will trigger method_missing
# Claude will generate the implementation, cache it, and execute it
puts "Calling fibonacci(10)..."
result = calc.fibonacci(10)
puts "Result: #{result}"
puts "Expected: 55"
puts ""

# Call it again - this time it should use the cached version
puts "Calling fibonacci(10) again (should use cache)..."
result2 = calc.fibonacci(10)
puts "Result: #{result2}"
puts ""

# Try another method
puts "Calling factorial(5)..."
result3 = calc.factorial(5)
puts "Result: #{result3}"
puts "Expected: 120"

