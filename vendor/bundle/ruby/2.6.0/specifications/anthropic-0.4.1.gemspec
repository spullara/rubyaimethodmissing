# -*- encoding: utf-8 -*-
# stub: anthropic 0.4.1 ruby lib

Gem::Specification.new do |s|
  s.name = "anthropic".freeze
  s.version = "0.4.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "changelog_uri" => "https://github.com/alexrudall/anthropic/blob/main/CHANGELOG.md", "homepage_uri" => "https://github.com/alexrudall/anthropic", "rubygems_mfa_required" => "true", "source_code_uri" => "https://github.com/alexrudall/anthropic" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Alex".freeze]
  s.bindir = "exe".freeze
  s.date = "2025-04-10"
  s.email = ["alexrudall@users.noreply.github.com".freeze]
  s.homepage = "https://github.com/alexrudall/anthropic".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.6.0".freeze)
  s.rubygems_version = "3.0.3.1".freeze
  s.summary = "Anthropic API + Ruby! \u{1F916}\u{1F30C}".freeze

  s.installed_by_version = "3.0.3.1" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<event_stream_parser>.freeze, [">= 0.3.0", "< 2.0.0"])
      s.add_runtime_dependency(%q<faraday>.freeze, [">= 1"])
      s.add_runtime_dependency(%q<faraday-multipart>.freeze, [">= 1"])
    else
      s.add_dependency(%q<event_stream_parser>.freeze, [">= 0.3.0", "< 2.0.0"])
      s.add_dependency(%q<faraday>.freeze, [">= 1"])
      s.add_dependency(%q<faraday-multipart>.freeze, [">= 1"])
    end
  else
    s.add_dependency(%q<event_stream_parser>.freeze, [">= 0.3.0", "< 2.0.0"])
    s.add_dependency(%q<faraday>.freeze, [">= 1"])
    s.add_dependency(%q<faraday-multipart>.freeze, [">= 1"])
  end
end
