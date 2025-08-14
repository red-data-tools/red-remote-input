# -*- ruby -*-

clean_white_space = lambda do |entry|
  entry.gsub(/(\A\n+|\n+\z)/, '') + "\n"
end

require_relative "lib/remote_input/version"

Gem::Specification.new do |spec|
  spec.name = "red-remote-input"
  spec.version = RemoteInput::VERSION
  spec.homepage = "https://github.com/red-data-tools/red-remote-input"
  spec.authors = ["Kouhei Sutou"]
  spec.email = ["kou@clear-code.com"]

  spec.summary = "A Ruby library for managing data download, cache, and extraction from URLs"
  spec.description = "A Ruby library for managing data download, cache, and extraction from URLs"
  spec.license = "MIT"
  spec.files = [
    "README.md",
    "LICENSE.txt",
    "Rakefile",
    "Gemfile",
    "#{spec.name}.gemspec",
  ]
  spec.files += Dir.glob("lib/**/*.rb")
  spec.files += Dir.glob("image/*.*")

  spec.add_runtime_dependency("rubyzip")

  spec.add_development_dependency("bundler")
  spec.add_development_dependency("rake")
  spec.add_development_dependency("test-unit")
  spec.add_development_dependency("yard")
  spec.add_development_dependency("kramdown")
end
