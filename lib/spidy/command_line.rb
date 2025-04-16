#
# spidy shell interface
#
class Spidy::CommandLine
  delegate :spidy, to: :@definition_file
  class_attribute :output, default: proc { |result| $stdout.puts(result.to_s) }

  class_attribute :error_handler, default: proc { |e, url|
    backtrace = e.backtrace.map { |line| "  #{line}" }.join("\n")
    warn <<~ERROR
      ======== Spidy Error ========
      URL: #{url}
      Error: #{e.class} - #{e.message}

      Backtrace:
      #{backtrace}
      ============================
    ERROR
  }

  def eval_call(script)
    @definition_file.spidy.instance_eval(script)
  end

  def initialize(definition_file)
    @definition_file = definition_file
    fail 'unloaded spidy' if definition_file.spidy.nil?
  end

  def each_stdin_lines(name)
    $stdin.each_line do |url|
      spidy.each(url.strip, name: name, &output)
    rescue StandardError => e
      error_handler.call(e, url)
    end
  end

  def call_stdin_lines(name)
    $stdin.each_line do |url|
      spidy.call(url.strip, name: name, &output)
    rescue StandardError => e
      error_handler.call(e, url)
    end
  end

  def call(name)
    return call_stdin_lines(name) if FileTest.pipe?($stdin)
    spidy.call(name: name, &output) unless FileTest.pipe?($stdin)
  rescue StandardError => e
    error_handler.call(e, nil)
  end

  def each(name)
    return each_stdin_lines(name) if FileTest.pipe?($stdin)
    spidy.each(name: name, &output)
  rescue StandardError => e
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
    File.write("#{name}.sh", build_shell_script(name))
    File.write("#{name}.rb", build_ruby_script)
  end

  def build_shell(name)
    <<~SHELL
      #!/bin/bash
      eval "$(spidy $(dirname "${0}")/#{name}.rb shell)"
      spider
    SHELL
  end

  def build_ruby
    <<~RUBY
      Spidy.define do
        spider(as: :html) do |yielder, connector|
          # connector.call(url) do |resource|
          #   yielder.call(url or resource)
          # end
        end

        define(as: :html) do
        end
      end
    RUBY
  end
end
