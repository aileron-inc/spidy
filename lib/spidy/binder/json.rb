# frozen_string_literal: true

#
# Bind json and convert to object
#
class Spidy::Binder::Json
  class << self
    attr_reader :names

    @names = []

    def let(name, *query, &block)
      @names << name
      define_method(name) do
        result = json.dig(*query) if query.present?
        return result if block.nil?

        instance_exec(result, &block)
      end
    end
  end

  attr_reader :json, :url

  def initialize(json, url: nil)
    @json = json
    @url = url
  end

  def to_s
    to_h.to_json
  end

  def to_h
    self.class.names.map { |name| [name, send(name)] }.to_h
  end
end
