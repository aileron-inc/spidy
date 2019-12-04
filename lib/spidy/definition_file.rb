# frozen_string_literal: true

#
# spidy interface binding
#
class Spidy::DefinitionFile
  attr_reader :path
  attr_reader :spidy

  def self.open(filepath)
    object = new(filepath)
    object.eval_definition
    object
  end

  # rubocop:disable Security/Eval
  def eval_definition
    @spidy = eval(File.open(path).read)
  end
  # rubocop:enable Security/Eval

  private

  def initialize(path)
    @path = path
  end
end
