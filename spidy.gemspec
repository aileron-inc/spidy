# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'spidy/version'

Gem::Specification.new do |spec|
  spec.name          = 'spidy'
  spec.version       = Spidy::VERSION
  spec.authors       = ['aileron']
  spec.email         = ['aileron.cc@gmail.com']

  spec.summary       = 'web spider dsl'
  # spec.description   = 'TODO: Write a longer description or delete this line.'
  spec.homepage      = 'https://github.com/aileron-inc/spidy'
  spec.license       = 'MIT'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'ffaker'
  spec.add_development_dependency 'rspec-command'

  spec.add_runtime_dependency 'activesupport'
  spec.add_runtime_dependency 'mechanize'
  spec.add_runtime_dependency 'socksify'
  spec.add_runtime_dependency 'pry'
end
