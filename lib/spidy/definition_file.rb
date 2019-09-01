# frozen_string_literal: true

#
# spidy interface binding
#
class Spidy::DefinitionFile
  attr_reader :path
  attr_reader :definition
  delegate :namespace, :spiders, to: :definition

  CSV = lambda do |result|
    ::CSV.generate do |csv|
      csv << result.definition.attributes_to_array
    end
  end

  def self.open(filepath)
    object = new(filepath)
    object.eval_definition
    object
  end

  # rubocop:disable Security/Eval
  def eval_definition
    @definition = eval(File.open(path).read)
  end
  # rubocop:enable Security/Eval

  def shell
    @shell ||= Spidy::Shell.new(self)
  end

  def console
    require 'pry'
    Pry.start(Spidy::Console.new(self))
  end

  private

  def initialize(path)
    @path = path
  end
end
