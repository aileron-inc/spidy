# frozen_string_literal: true

#
# Bind json and convert to object
#
module Spidy::Binder::Json
  #
  # Describe the definition to get the necessary elements from the resource object
  #
  class Resource
    class_attribute :names, default: []
    attr_reader :json

    def initialize(json)
      @json = json
      @source = json
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

  def self.call(resource, define_block)
    binder = Class.new(Resource) { instance_exec(&define_block) }
    yield binder.new(resource)
  end
end
