# Claude Helper for Spidy

## Build/Test/Lint Commands
- Install dependencies: `bundle install`
- Run all tests: `bundle exec rake spec`
- Run single test: `bundle exec rspec spec/path/to_spec.rb:LINE_NUMBER`
- Install gem locally: `bundle exec rake install`
- Release gem: `bundle exec rake release`

## Code Style Guidelines
- **Naming Conventions**: 
  - snake_case for methods/variables/files
  - CamelCase for classes/modules
  - SCREAMING_SNAKE_CASE for constants
- **File Organization**: Match file paths to module/class hierarchy
- **Imports**: 
  - Add `# frozen_string_literal: true` at file start
  - Use `extend ActiveSupport::Autoload` for modules with sub-modules
- **Error Handling**: Create custom error classes inheriting from StandardError
- **Documentation**: Add brief comments before classes and methods
- **Testing**: 
  - Use RSpec with `expect` syntax 
  - Organize with `describe` and `specify` blocks
  - Name test files with `_spec.rb` suffix

## Dependencies
- Runtime: activesupport, mechanize, socksify, tor
- Development: bundler, capybara_discoball, ffaker, rake, rspec, sinatra