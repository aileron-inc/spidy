#
# spidy console
#
class Spidy::Console
  delegate :spidy, to: :@definition_file
  delegate :call, :each, :namespace, allow_nil: true, to: :spidy

  def initialize(definition_file)
    @definition_file = definition_file
  end

  def open(filepath)
    @definition_file = Spidy::DefinitionFile.open(filepath)
  end

  def reload!
    @definition_file.eval_definition
  end

  def connector(url, as:)
    connector = Spidy::Connector.get(as)
    connector.call(url) { |page| break page }
  end
end
