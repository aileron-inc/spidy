# frozen_string_literal: true

#
# spidy console
#
class Spidy::Console
  attr_reader :definition_file
  delegate :spidy, to: :definition_file

  def initialize(definition_file = nil)
    @definition_file = definition_file
  end

  def open(filepath)
    @definition_file = Spidy::DefinitionFile.open(filepath)
  end

  def reload!
    @definition_file&.eval_definition
  end

  def call(name = :default, url = nil, &block)
    spidy.call(name, url: url, &block)
  end

  def each(name = :default, url = nil, &block)
    spidy.each(name, url: url, &block)
  end
end
