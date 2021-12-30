# frozen_string_literal: true

#
# An object that represents the scraper defined by define block.
#
class Spidy::DefinitionObject
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
    self.class.attribute_names.to_h { |name| [name, send(name)] }
  end
end
