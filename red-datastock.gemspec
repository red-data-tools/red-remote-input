# -*- ruby -*-

clean_white_space = lambda do |entry|
  entry.gsub(/(\A\n+|\n+\z)/, '') + "\n"
end

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "lib"))
require "datastock/version"

Gem::Specification.new do |spec|
  spec.name = "red-datastock"
  spec.version = DataStock::VERSION
  spec.homepage = "https://github.com/red-data-tools/red-datastock"
  spec.authors = ["Kouhei Sutou"]
  spec.email = ["kou@clear-code.com"]

  readme = File.read("README.md")
  readme.force_encoding("UTF-8")
  entries = readme.split(/^\#\#\s(.*)$/)
  clean_white_space.call(entries[entries.index("Description") + 1])
  description = clean_white_space.call(entries[entries.index("Description") + 1])
  spec.summary, spec.description, = description.split(/\n\n+/, 3)
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
