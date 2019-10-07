# frozen_string_literal: true

require 'pry'

#
# spidy shell interface
#
class Spidy::Shell
  attr_reader :definition_file, :spidy
  class_attribute :output, default: (proc { |result| STDOUT.puts(result.to_s) })
  class_attribute :error_handler, default: (proc { |e, url| STDERR.puts("#{url}\n #{e.message}") })
  delegate :spidy, to: :definition_file

  def initialize(definition_file)
    @definition_file = definition_file
  end

  def call(name)
    return spidy.call(name, stream: STDIN, err: error_handler, &output) if FileTest.pipe?(STDIN)

    spidy.call(name, err: error_handler, &output)
  end

  def each(name)
    return spidy.each(name, stream: STDIN, err: error_handler, &output) if FileTest.pipe?(STDIN)

    spidy.each(name, err: error_handler, &output)
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
end
