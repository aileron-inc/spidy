# frozen_string_literal: true

#
# Bind json and convert to object
#
class Spidy::Binder::Json
  class_attribute :names, default: []
  attr_reader :json, :source, :url

  def initialize(json, url: nil)
    @json = json
    @url = url
    @source = json.to_json
  end

  def to_s
    to_h.to_json
  end

  def to_h
    names.map { |name| [name, send(name)] }.to_h
  end

  def self.let(name, *query, &block)
    names << name
    define_method(name) do
      result = json.dig(*query) if query.present?
      return result if block.nil?

      instance_exec(result, &block)
    end
  end
end
