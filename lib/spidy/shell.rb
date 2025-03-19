# frozen_string_literal: true

#
# spidy Shell
#
class Spidy::Shell
  def initialize(path)
    @definition_file = Spidy::DefinitionFile.open(path)
  end

  def interactive
    console = Spidy::Console.new(@definition_file)
    require 'irb'
    IRB.setup(nil)
    irb = IRB::Irb.new(IRB::WorkSpace.new(console))
    IRB.conf[:MAIN_CONTEXT] = irb.context
    irb.eval_input
  end

  def command_line
    Spidy::CommandLine.new(@definition_file)
  end

  delegate :function, :each, :call, :eval_call, to: :command_line
end
