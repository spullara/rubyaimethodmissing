#!/usr/bin/env ruby

require_relative 'lib/ai_methods'

puts "Testing Error Recovery / Self-Healing..."
puts "=" * 60

# Track API calls and retries
$api_calls = 0
$retry_count = 0

# Mock the AIMethods Client to simulate error recovery
module AIMethods
  class Client
    def initialize
      # Mock initialization
    end
    
    def generate_code(method_name, args, context: nil, block_given: false)
      $api_calls += 1
      puts "  [API CALL ##{$api_calls}] Generating code for #{method_name}(#{args.inspect})"
      
      # First call: generate buggy code that will fail
      if $api_calls == 1
        puts "    → Generating BUGGY code (will fail)"
        # This code will fail because 5.complex_math doesn't exist
        "def complex_math(n)\n  n.complex_math\nend\ncomplex_math(#{args[0]})"
      else
        # Should not reach here in this test
        "def complex_math(n)\n  n * 2\nend\ncomplex_math(#{args[0]})"
      end
    end
    
    def fix_code(method_name, args, context: nil, block_given: false, original_code: nil, error_class: nil, error_message: nil)
      $api_calls += 1
      $retry_count += 1
      puts "  [API CALL ##{$api_calls}] FIXING code after #{error_class}"
      puts "    → Error was: #{error_message}"
      puts "    → Generating FIXED code"
      
      # Return fixed code
      "def complex_math(n)\n  n * 2\nend\ncomplex_math(#{args[0]})"
    end
  end
end

class Calculator
  include AIMethods
end

# Test 1: Error recovery with retry
puts "\n1. Testing error recovery with retry..."
begin
  calc = Calculator.new
  result = calc.complex_math(5)
  
  if result == 10
    puts "✓ Error recovery worked! Got correct result: #{result}"
    puts "  - API calls made: #{$api_calls}"
    puts "  - Retries triggered: #{$retry_count}"
    
    if $retry_count == 1
      puts "✓ Exactly 1 retry was triggered"
    else
      puts "✗ Expected 1 retry, got #{$retry_count}"
      exit 1
    end
  else
    puts "✗ Expected 10, got #{result}"
    exit 1
  end
rescue => e
  puts "✗ Error recovery failed: #{e.class}: #{e.message}"
  exit 1
end

# Test 2: Verify code is cached after successful execution
puts "\n2. Testing cache after successful execution..."
$api_calls = 0
$retry_count = 0

begin
  calc2 = Calculator.new
  result2 = calc2.complex_math(7)
  
  if result2 == 14
    puts "✓ Cached code executed successfully: #{result2}"
    
    if $api_calls == 0
      puts "✓ No API calls made (code was cached)"
    else
      puts "✗ Expected 0 API calls, got #{$api_calls}"
      exit 1
    end
  else
    puts "✗ Expected 14, got #{result2}"
    exit 1
  end
rescue => e
  puts "✗ Cached execution failed: #{e.class}: #{e.message}"
  exit 1
end

puts "\n" + "=" * 60
puts "All error recovery tests passed! ✓"

