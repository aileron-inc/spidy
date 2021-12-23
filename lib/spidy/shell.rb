# frozen_string_literal: true

#
# spidy Shell
#
class Spidy::Shell
  def initialize(path)
    @definition_file = Spidy::DefinitionFile.open(path)
  end

  def interactive
    Pry.start(Spidy::Console.new(@definition_file))
  end

  def command_line
    Spidy::CommandLine.new(@definition_file)
  end

  delegate :function, :each, :call, :eval_call, to: :command_line
end
