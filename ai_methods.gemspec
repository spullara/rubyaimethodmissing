require_relative "lib/ai_methods/version"

Gem::Specification.new do |spec|
  spec.name          = "ai_methods"
  spec.version       = AIMethods::VERSION
  spec.authors       = ["Sam Pullara"]
  spec.email         = ["spullara@gmail.com"]
  spec.summary       = "AI-powered method implementation using Claude"
  spec.description   = "Automatically implement Ruby methods using Claude AI with caching support"
  spec.homepage      = "https://github.com/spullara/rubyaimethodmissing"
  spec.license       = "MIT"

  spec.files         = Dir.glob("lib/**/*") + ["Gemfile", "README.md", "LICENSE"]
  spec.require_paths = ["lib"]

  spec.add_dependency "anthropic"
  spec.add_dependency "sqlite3"
  spec.add_dependency "dotenv"
  spec.add_dependency "method_source"

  spec.required_ruby_version = ">= 2.7.0"
end

