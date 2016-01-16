# -*- mode: ruby; coding: utf-8 -*-

clean_white_space = lambda do |entry|
  entry.gsub(/(\A\n+|\n+\z)/, '') + "\n"
end

require "./lib/test/unit/capybara/version"

version = Test::Unit::Capybara::VERSION.dup

Gem::Specification.new do |spec|
  spec.name = "test-unit-capybara"
  spec.version = version
  spec.homepage = "https://github.com/test-unit/test-unit-capybara"
  spec.authors = ["Kouhei Sutou"]
  spec.email = ["kou@clear-code.com"]
  entries = File.read("README.textile").split(/^h2\.\s(.*)$/)
  description = clean_white_space.call(entries[entries.index("Description") + 1])
  spec.summary, spec.description, = description.split(/\n\n+/, 3)
  spec.license = "LGPLv2 or later"
  spec.files += Dir.glob("lib/**/*.rb")
  spec.files += Dir.glob("bin/*")
  spec.files += Dir.glob("doc/text/*")
  spec.files += ["README.textile", "COPYING", "Rakefile", "Gemfile"]
  spec.test_files = Dir.glob("test/**/*.rb")

  spec.add_runtime_dependency("test-unit", ">=2.5.3")
  spec.add_runtime_dependency("capybara", ">=2.1.0")
  spec.add_runtime_dependency("json")

  spec.add_development_dependency("bundler")
  spec.add_development_dependency("rake")
  spec.add_development_dependency("yard")
  spec.add_development_dependency("packnga")
  spec.add_development_dependency("test-unit-notify")
  spec.add_development_dependency("RedCloth")
end
