# frozen_string_literal: true

require_relative "lib/translation_tools/version"

Gem::Specification.new do |spec|
  spec.name = "translation_tools"
  spec.version = TranslationTools::VERSION
  spec.authors = ["Kaleb Lape"]
  spec.email = ["kaleb.lape@gmail.com"]

  spec.summary = "A set of tools for managing and processing translations in Ruby projects."
  spec.description = "TranslationTools provides utilities for working with translation files, including CSV processing, diff generation, and more. It aims to simplify the management of multilingual content in Ruby applications."
  spec.homepage = "https://github.com/Ungerware/translation_tools"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/Ungerware/translation_tools"
  spec.metadata["changelog_uri"] = "https://github.com/Ungerware/translation_tools/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Dependencies
  spec.add_dependency "csv", "~> 3.3"
  spec.add_dependency "diffy", "~> 3.4"

  # Development dependencies
  spec.add_development_dependency "rspec", "~> 3.10"
  spec.add_development_dependency "rubocop", "~> 1.21"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
