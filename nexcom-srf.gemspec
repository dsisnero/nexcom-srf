# frozen_string_literal: true

require_relative "lib/nexcom/srf/version"

Gem::Specification.new do |spec|
  spec.name = "nexcom-srf"
  spec.version = Nexcom::Srf::VERSION
  spec.authors = ["dsisnero"]
  spec.email = ["dsisnero@gmail.com"]

  spec.summary = "This package fills in a SRF form for NEXCOM"
  spec.homepage = "https://github.com/dsisnero/nexcom-srf"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = spec.homepage + "CHANGLELOG.md"
  spec.metadata["allowed_push_host"] = "https://rubygems.pkg.github.com/dsisnero/"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) || f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "dry-types"
  spec.add_dependency "dry-struct"
  spec.add_dependency "robust_excel_ole"
  spec.add_dependency "concurrent-ruby"
  # spec.add_development_dependency "standard"
  spec.add_development_dependency "minitest"
  spec.add_development_dependency "guard-minitest"
  # spec.add_development_dependency "solargraph-standardrb"

  # spec.add_dependency "dry-core", "~> 1.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
