# frozen_string_literal: true

require_relative "lib/url_normalizer/version"

Gem::Specification.new do |spec|
  spec.name          = "url_normalizer"
  spec.version       = UrlNormalizer::VERSION
  spec.authors       = ["Anna"]
  spec.email         = ["anna.ryzhko@student.karazin.ua"]

  spec.summary       = %q{A Ruby gem for URL normalization: parameter sorting and removal of utm/* tracking codes.}
  spec.description   = %q{Provides a simple, fast method to normalize a URL by alphabetically sorting its query parameters and stripping common utm_* tracking parameters, which is useful for caching and deduplication.}
  spec.homepage      = "https://github.com/RyzhkoAnna/Ruby-labs"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.5.0")

  # Вказуємо файли, які повинні бути включені в гем
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Залежності для розробки (тестування)
  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end