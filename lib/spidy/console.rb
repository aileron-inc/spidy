# frozen_string_literal: true

#
# spidy console
#
class Spidy::Console
  attr_reader :definition_file
  delegate :spidy, to: :definition_file
  delegate :call, :each, to: :spidy

  def initialize(definition_file = nil)
    @definition_file = definition_file
  end

  def open(filepath)
    @definition_file = Spidy::DefinitionFile.open(filepath)
  end

  def reload!
    @definition_file&.eval_definition
  end
end
