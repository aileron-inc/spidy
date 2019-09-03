# frozen_string_literal: true

require 'pry'

#
# spidy shell interface
#
class Spidy::Shell
  attr_reader :definition_file
  class_attribute :output_yielder, default: (proc { |result| STDOUT.puts(result.to_s) })
  delegate :namespace, :spiders, to: :definition_file

  def initialize(definition_file)
    @definition_file = definition_file
  end

  def call(name)
    exec(namespace[name&.to_sym] || namespace.values.first)
  end

  def each(name)
    exec(spiders[name&.to_sym] || spiders.values.first)
  end

  def function
    print <<~SHELL
      function spider() {
        spidy spider #{definition_file.path} $1
      }
      function scraper() {
        spidy call #{definition_file.path} $1
      }
    SHELL
  end

  def build(name)
    build_shell(name)
    build_ruby(name)
  end

  def build_shell(name)
    File.open("#{name}.sh", 'w') do |f|
      f.write <<~SHELL
        #!/bin/bash
        eval "$(spidy $(dirname "${0}")/#{name}.rb shell)"
        spider example
      SHELL
    end
  end

  def build_ruby(name)
    File.open("#{name}.rb", 'w') do |f|
      f.write <<~RUBY
        # frozen_string_literal: true

        Spidy.define do
          spider(:example) do |yielder, connector|
            # connector.call(url) do |resource|
            #   yielder.call(url or resource)
            # end
          end

          define(:example) do
          end
        end
      RUBY
    end
  end

  private

  def exec(command)
    fail "undefined commmand[#{name}]" if command.nil?
    return command.call(&output_yielder) unless FileTest.pipe?(STDIN)

    STDIN.each do |line|
      command.call(line.strip, &output_yielder)
    rescue StandardError => e
      STDERR.puts("#{line.strip} => \n #{e.message}")
    end
  end
end
