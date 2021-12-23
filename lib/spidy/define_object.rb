class Spidy::DefineObject
  class << self
    attr_reader :attribute_names
  end
  attr_reader :resource, :url

  def initialize(resource, url)
    @resource = resource
    @url = url
  end

  def to_s
    to_h.to_json
  end

  def to_h
    self.class.attribute_names.map { |name| [name, send(name)] }.to_h
  end
end
