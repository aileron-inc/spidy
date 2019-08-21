# frozen_string_literal: true

#
# spidy shell interface
#
class Spidy::Shell
  attr_reader :definition_file
  delegate :spiders, :scrapers, to: :definition_file

  def initialize(definition_file)
    @definition_file = definition_file
  end

  def scraper(name)
    command = scrapers[name&.to_sym] || scrapers.values.first
    fail "undefined commmand[#{name}]" if command.nil?
    return command.call(&definition_file.output) unless FileTest.pipe?(STDIN)

    STDIN.each do |line|
      command.call(line.strip, &definition_file.output)
    rescue StandardError
      STDERR.puts "ERROR #{url}: #{$ERROR_INFO}\n#{$ERROR_INFO.backtrace}"
    end
  end

  def spider(name)
    command = spiders[name&.to_sym] || spiders.values.first
    fail "undefined commmand[#{name}]" if command.nil?
    return command.call { |url| puts url } unless File.pipe?(STDIN)

    STDIN.each_line do |line|
      command.call(line.strip) { |url| puts url }
    end
  end

  def function
    print <<~SHELL
      function spider() {
        spidy spider #{definition_file.path} $1
      }
      function scraper() {
        spidy scraper #{definition_file.path} $1
      }
    SHELL
  end

  # rubocop:disable Metrics/MethodLength
  def build(name)
    File.open("#{name}.rb", 'w') do |f|
      f.write <<~RUBY
        # frozen_string_literal: true

        Spidy.define(:#{name}) do
          spider(:example, 'http://example.com') do |html, yielder|
            #  yielder.call(url or resource)
          end

          scraper(:example) do
          end
        end
      RUBY
    end

    File.open("#{name}.sh", 'w') do |f|
      f.write <<~SHELL
        #!/bin/bash
        eval "$(spidy $(dirname "${0}")/#{name}.rb shell)"
        spider example
      SHELL
    end
  end
  # rubocop:enable Metrics/MethodLength
end
