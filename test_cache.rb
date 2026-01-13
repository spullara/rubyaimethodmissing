#!/usr/bin/env ruby

require 'fileutils'
require_relative 'lib/ai_methods/cache'

# Clean up test database
test_db = File.expand_path('~/.ai_methods/test_cache.db')
FileUtils.rm_f(test_db)

puts "Testing AIMethods::Cache..."
puts "=" * 50

# Test 1: Initialize cache
puts "\n1. Testing Cache.new with custom path..."
cache = AIMethods::Cache.new(test_db)
puts "✓ Cache initialized successfully"

# Test 2: Store a method
puts "\n2. Testing #store..."
cache.store("Calculator", "fibonacci", "n", "n <= 1 ? n : fibonacci(n-1) + fibonacci(n-2)")
cache.store("Calculator", "factorial", "n", "n <= 1 ? 1 : n * factorial(n-1)")
cache.store("StringUtils", "reverse", "str", "str.reverse")
puts "✓ Methods stored successfully"

# Test 3: Find a single method
puts "\n3. Testing #find..."
code = cache.find("Calculator", "fibonacci", "n")
if code == "n <= 1 ? n : fibonacci(n-1) + fibonacci(n-2)"
  puts "✓ Found fibonacci method correctly"
else
  puts "✗ Failed to find fibonacci method"
  exit 1
end

# Test 4: Find non-existent method
puts "\n4. Testing #find with non-existent method..."
code = cache.find("Calculator", "nonexistent", "")
if code.nil?
  puts "✓ Correctly returned nil for non-existent method"
else
  puts "✗ Should have returned nil"
  exit 1
end

# Test 5: Find all methods for a class
puts "\n5. Testing #find_all_for_class..."
methods = cache.find_all_for_class("Calculator")
if methods.length == 2 && methods[0][:method_name] == "fibonacci" && methods[1][:method_name] == "factorial"
  puts "✓ Found all methods for Calculator class"
  puts "  - #{methods[0][:method_name]}"
  puts "  - #{methods[1][:method_name]}"
else
  puts "✗ Failed to find all methods"
  exit 1
end

# Test 6: Find all for different class
puts "\n6. Testing #find_all_for_class for different class..."
methods = cache.find_all_for_class("StringUtils")
if methods.length == 1 && methods[0][:method_name] == "reverse"
  puts "✓ Found method for StringUtils class"
else
  puts "✗ Failed to find StringUtils methods"
  exit 1
end

# Test 7: Touch method (update last_used_at and call_count)
puts "\n7. Testing #touch..."
cache.touch("Calculator", "fibonacci", "n")
cache.touch("Calculator", "fibonacci", "n")
puts "✓ Touch executed successfully"

# Test 8: Verify INSERT OR REPLACE works
puts "\n8. Testing INSERT OR REPLACE behavior..."
cache.store("Calculator", "fibonacci", "n", "updated_code_here")
code = cache.find("Calculator", "fibonacci", "n")
if code == "updated_code_here"
  puts "✓ INSERT OR REPLACE works correctly"
else
  puts "✗ INSERT OR REPLACE failed"
  exit 1
end

# Test 9: Test with default path (~/. ai_methods/cache.db)
puts "\n9. Testing default path expansion..."
default_cache = AIMethods::Cache.new
puts "✓ Default cache initialized at ~/.ai_methods/cache.db"
default_cache.close

# Test 10: Close connection
puts "\n10. Testing #close..."
cache.close
puts "✓ Cache closed successfully"

puts "\n" + "=" * 50
puts "All tests passed! ✓"

