# AI Method Missing

A Ruby gem that implements `method_missing` using Claude Opus 4.5 to generate executable Ruby code on-the-fly.

## How It Works

When you call an undefined method on a class that includes `AIMethods`, the gem:

1. Intercepts the call via Ruby's `method_missing`
2. Checks SQLite cache for a previously generated implementation
3. If not cached, sends the method name, arguments, and class context to Claude Opus 4.5
4. Claude generates Ruby code to implement the requested behavior
5. The code is executed and the result returned
6. Generated methods are cached in SQLite for persistence across sessions

## Installation

```bash
gem install ai_methods
```

Or add to your Gemfile:

```ruby
gem 'ai_methods'
```

## Setup

Create a `.env` file with your Anthropic API key:

```
ANTHROPIC_API_KEY=sk-ant-your-key-here
```

## Usage

```ruby
require 'ai_methods'

class Calculator
  include AIMethods

  def add(a, b)
    a + b
  end
end

calc = Calculator.new

# Claude generates fibonacci implementation
result = calc.fibonacci(10)
puts result  # => 55

# Claude generates factorial, can reference existing methods
calc.factorial(5)  # => 120

# Second call uses cached implementation - no API call!
calc.fibonacci(20)  # => 6765
```

## Running the Examples

```bash
# Install dependencies
bundle install

# Set up your API key
cp .env.example .env
# Edit .env and add your ANTHROPIC_API_KEY

# Run the calculator example
bundle exec ruby examples/calculator.rb
```

The calculator example demonstrates:
- Generating fibonacci and factorial methods
- Caching (second call uses cached code)
- Method generation with full context

## Features

- **Automatic Code Generation**: Just call any method and Claude figures out what you want
- **Smart Context**: Claude sees existing class methods and previously generated methods
- **SQLite Persistence**: Generated methods survive across program restarts
- **Method Reuse**: Generated methods can call each other and existing class methods

## Configuration

```ruby
AIMethods.configure do |config|
  config.model = 'claude-opus-4-20250514'  # Default
  config.db_path = '~/.ai_methods/cache.db'  # Default
  config.max_tokens = 4096  # Default
end
```

## How Context Works

When generating a new method, Claude receives:

1. **Existing class methods** - Methods you've defined on the class
2. **Previously generated methods** - All AI-generated methods for this class from the cache

This allows Claude to:
- Reuse existing functionality
- Build on previously generated methods
- Maintain consistency across generated code

## Example: Building a Math Library

```ruby
class MathLib
  include AIMethods
end

math = MathLib.new

# Each call generates and caches the implementation
math.fibonacci(10)      # Generates fibonacci
math.factorial(5)       # Generates factorial
math.is_prime?(17)      # Generates primality check
math.gcd(48, 18)        # Generates greatest common divisor

# Claude can now see all 4 methods when generating the 5th
math.lcm(12, 8)         # May use gcd() internally!
```

## Dependencies

- `anthropic` - Claude API client
- `sqlite3` - Persistent method cache
- `dotenv` - Environment variable loading
- `method_source` - Extract source code of existing methods (optional)

## License

MIT
