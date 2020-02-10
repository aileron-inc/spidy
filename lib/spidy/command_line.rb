# frozen_string_literal: true

#
# spidy shell interface
#
class Spidy::CommandLine
  delegate :spidy, to: :@definition_file
  class_attribute :output, default: (proc { |result| STDOUT.puts(result.to_s) })
  class_attribute :error_handler, default: (proc { |e, url| STDERR.puts({ url: url, message: e.message, backtrace: e.backtrace }.to_json) })

  def initialize(definition_file)
    @definition_file = definition_file
    raise 'unloaded spidy' if definition_file.spidy.nil?
  end

  def each_stdin_lines(name)
    STDIN.each_line do |url|
      begin
        spidy.each(url.strip, name: name, &output)
      rescue => e
        error_handler.call(e, url)
      end
    end
  end

  def call_stdin_lines(name)
    STDIN.each_line do |url|
      begin
        spidy.call(url.strip, name: name, &output)
      rescue => e
        error_handler.call(e, url)
      end
    end
  end

  def call(name)
    return call_stdin_lines(name) if FileTest.pipe?(STDIN)
    spidy.call(name: name, &output) unless FileTest.pipe?(STDIN)
  rescue => e
    error_handler.call(e, nil)
  end

  def each(name)
    return each_stdin_lines(name) if FileTest.pipe?(STDIN)
    spidy.each(name: name, &output)
  rescue => e
    error_handler.call(e, nil)
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
