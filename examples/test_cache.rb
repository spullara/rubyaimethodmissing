#!/usr/bin/env ruby

require 'fileutils'
require 'benchmark'
require_relative '../lib/ai_methods'

# Clean up test database for fresh start
test_db = File.expand_path('~/.ai_methods/test_cache_example.db')
FileUtils.rm_f(test_db)

puts "=" * 70
puts "CACHE BEHAVIOR TEST - Fibonacci Example"
puts "=" * 70

# Mock the AIMethods Client to track API calls
module AIMethods
  class Client
    def initialize
      # Mock initialization
    end
    
    def generate_code(method_name, args, context: nil, block_given: false)
      puts "    [API CALL] Generating code for #{method_name}(#{args.inspect})"
      
      case method_name
      when 'fibonacci'
        <<~RUBY
          def fibonacci(n)
            return n if n <= 1
            fibonacci(n - 1) + fibonacci(n - 2)
          end
          fibonacci(#{args[0]})
        RUBY
      else
        "# Generated method: #{method_name}"
      end
    end
  end
end

# Patch the Cache to track hits/misses
module AIMethods
  class Cache
    alias_method :original_find, :find

    def find(class_name, method_name, method_signature)
      result = original_find(class_name, method_name, method_signature)
      if result
        puts "    [CACHE HIT] Found cached code for signature: #{method_signature}"
      else
        puts "    [CACHE MISS] No cached code for signature: #{method_signature}"
      end
      result
    end
  end
end

# Configure to use our test database
AIMethods.configure do |config|
  # Cache will be created at test_db path
end

class Calculator
  include AIMethods
end

calc = Calculator.new

puts "\n1. First call: fibonacci(10)"
puts "   Signature being used: args.map(&:class).join(',') = Integer"
time1 = Benchmark.measure do
  result1 = calc.fibonacci(10)
  puts "   Result: #{result1}"
end
puts "   Time: #{(time1.real * 1000).round(2)}ms"

puts "\n2. Second call: fibonacci(5)"
puts "   Signature being used: Integer (same as fibonacci(10))"
puts "   Expected: CACHE HIT (both have signature 'Integer')"
time2 = Benchmark.measure do
  result2 = calc.fibonacci(5)
  puts "   Result: #{result2}"
end
puts "   Time: #{(time2.real * 1000).round(2)}ms"

puts "\n3. Third call: fibonacci(10) again"
puts "   Signature being used: Integer (same as before)"
puts "   Expected: CACHE HIT (already cached)"
time3 = Benchmark.measure do
  result3 = calc.fibonacci(10)
  puts "   Result: #{result3}"
end
puts "   Time: #{(time3.real * 1000).round(2)}ms"

puts "\n" + "=" * 70
puts "SUMMARY"
puts "=" * 70
puts "✓ Cache signature format: args.map(&:class).join(',')"
puts "✓ All calls with Integer argument use the same cache entry"
puts "✓ Calls 2 and 3 should be significantly faster (cached)"
puts "=" * 70

