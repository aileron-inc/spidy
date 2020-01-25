# frozen_string_literal: true

#
# Bind json and convert to object
#
class Spidy::Binder::Json
  class << self
    attr_reader :attribute_names

    def let(name, *query, &block)
      @attribute_names ||= []
      @attribute_names << name
      define_method(name) do
        result = json.dig(*query) if query.present?
        return result if block.nil?

        instance_exec(result, &block)
      end
    end
  end

  attr_reader :json, :url
  alias_method :resource, :json

  def initialize(spidy, json, url)
    @spidy = spidy
    @json = json
    @url = url
  end

  def scraper(name, source)
    lambda { |&block| @spidy.call(source, name: name, &block) }
  end

  def to_s
    to_h.to_json
  end

  def to_h
    self.class.attribute_names.map { |name| [name, send(name)] }.to_h
  end
end
