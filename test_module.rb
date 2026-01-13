#!/usr/bin/env ruby

require_relative 'lib/ai_methods'

puts "Testing AIMethods module..."
puts "=" * 50

# Test 1: Module can be included
puts "\n1. Testing module inclusion..."
class TestClass
  include AIMethods
end

puts "✓ AIMethods module can be included in a class"

# Test 2: Instance has method_missing
puts "\n2. Testing method_missing is available..."
obj = TestClass.new
if obj.respond_to?(:method_missing)
  puts "✓ method_missing is available"
else
  puts "✗ method_missing not found"
  exit 1
end

# Test 3: respond_to_missing? returns true
puts "\n3. Testing respond_to_missing?..."
if obj.respond_to?(:any_method_name)
  puts "✓ respond_to_missing? returns true for any method"
else
  puts "✗ respond_to_missing? not working"
  exit 1
end

# Test 4: Check that the module has the right methods
puts "\n4. Testing module structure..."
if AIMethods.respond_to?(:configuration)
  puts "✓ AIMethods.configuration exists"
else
  puts "✗ AIMethods.configuration not found"
  exit 1
end

if AIMethods.respond_to?(:configure)
  puts "✓ AIMethods.configure exists"
else
  puts "✗ AIMethods.configure not found"
  exit 1
end

# Test 5: Configuration is initialized
puts "\n5. Testing configuration..."
config = AIMethods.configuration
if config.is_a?(AIMethods::Configuration)
  puts "✓ Configuration is initialized"
else
  puts "✗ Configuration not initialized"
  exit 1
end

puts "\n" + "=" * 50
puts "All module tests passed! ✓"

