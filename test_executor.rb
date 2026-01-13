#!/usr/bin/env ruby

require_relative 'lib/ai_methods/executor'

puts "Testing AIMethods::Executor..."
puts "=" * 50

executor = AIMethods::Executor.new

# Test 1: Simple code execution
puts "\n1. Testing simple code execution..."
result = executor.execute("2 + 2", binding)
if result == 4
  puts "✓ Simple arithmetic works"
else
  puts "✗ Failed: expected 4, got #{result}"
  exit 1
end

# Test 2: Code with markdown wrapper (```ruby)
puts "\n2. Testing markdown stripping (```ruby)..."
code_with_markdown = "```ruby\n5 * 3\n```"
result = executor.execute(code_with_markdown, binding)
if result == 15
  puts "✓ Markdown stripping works"
else
  puts "✗ Failed: expected 15, got #{result}"
  exit 1
end

# Test 3: Code with generic markdown wrapper (```)
puts "\n3. Testing markdown stripping (generic ```)..."
code_with_generic = "```\n10 + 5\n```"
result = executor.execute(code_with_generic, binding)
if result == 15
  puts "✓ Generic markdown stripping works"
else
  puts "✗ Failed: expected 15, got #{result}"
  exit 1
end

# Test 4: Validate valid code
puts "\n4. Testing validate with valid code..."
begin
  executor.validate("x = 42; x * 2")
  puts "✓ Valid code passes validation"
rescue SyntaxError
  puts "✗ Valid code should not raise SyntaxError"
  exit 1
end

# Test 5: Validate invalid code
puts "\n5. Testing validate with invalid code..."
begin
  executor.validate("def foo(")
  puts "✗ Invalid code should raise SyntaxError"
  exit 1
rescue SyntaxError => e
  if e.message.include?("invalid syntax")
    puts "✓ Invalid code raises SyntaxError with proper message"
  else
    puts "✓ Invalid code raises SyntaxError"
  end
end

# Test 6: Strip markdown with no wrappers
puts "\n6. Testing strip_markdown with no wrappers..."
clean = executor.strip_markdown("puts 'hello'")
if clean == "puts 'hello'"
  puts "✓ Code without markdown is unchanged"
else
  puts "✗ Failed: expected 'puts 'hello'', got #{clean}"
  exit 1
end

# Test 7: Execute with binding context
puts "\n7. Testing execution with binding context..."
x = 10
result = executor.execute("x + 5", binding)
if result == 15
  puts "✓ Execution with binding context works"
else
  puts "✗ Failed: expected 15, got #{result}"
  exit 1
end

# Test 8: Runtime error handling
puts "\n8. Testing runtime error handling..."
begin
  executor.execute("1 / 0", binding)
  puts "✗ Should have raised RuntimeError"
  exit 1
rescue RuntimeError => e
  if e.message.include?("execution failed")
    puts "✓ Runtime errors are caught and wrapped"
  else
    puts "✓ Runtime error raised"
  end
end

# Test 9: Syntax error handling
puts "\n9. Testing syntax error handling..."
begin
  executor.execute("if true", binding)
  puts "✗ Should have raised SyntaxError"
  exit 1
rescue SyntaxError => e
  if e.message.include?("invalid syntax")
    puts "✓ Syntax errors are caught and wrapped"
  else
    puts "✓ Syntax error raised"
  end
end

# Test 10: Complex code execution
puts "\n10. Testing complex code execution..."
complex_code = <<~RUBY
  def fibonacci(n)
    return n if n <= 1
    fibonacci(n - 1) + fibonacci(n - 2)
  end
  fibonacci(6)
RUBY
result = executor.execute(complex_code, binding)
if result == 8
  puts "✓ Complex code execution works"
else
  puts "✗ Failed: expected 8, got #{result}"
  exit 1
end

puts "\n" + "=" * 50
puts "All tests passed! ✓"

