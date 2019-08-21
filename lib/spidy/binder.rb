# frozen_string_literal: true

#
# Bind resource received from the connection to the result object
#
class Spidy::Binder
  #
  # binding multiple
  #
  class Multiple
    def self.bind(connector:, binder:, query:, block:)
      multiple_binding_class = self
      connector.field.call(binder, query) do |elements|
        multiple_binding_class.new(binder.class).instance_exec(elements, &block)
      end
    end

    def initialize(binder)
      @binder = binder
    end

    def field(name)
      @binder.field_names << name
      @binder.field_names.uniq!
      @binder.result_class.define(name)
      result = yield
      @binder.define_method(name) { result }
    end
  end

  class_attribute :field_names, default: []
  attr_reader :resource

  def initialize(resource)
    @resource = resource
    self.class.fields_call(self)
  end

  def result
    definition = self
    fetched_at = Time.current
    result = self.class.result_class.new(fetched_at: fetched_at, fetched_on: fetched_at.beginning_of_day, **attributes)
    result.define_singleton_method(:resource) { definition.resource }
    result
  end

  def attributes_to_array
    field_names.map { |field_name| send(field_name) }
  end

  def attributes
    field_names.map { |field_name| [field_name, send(field_name)] }.to_h
  end

  def self.query(name, query = nil, &block)
    define_method(name) do
      connector.field.call(self, query, &block)
    end
  end

  def self.field(name, query = nil, optional: false, &block)
    field_names << name
    field_names.uniq!
    result_class.define(name, presence: !optional)
    define_method(name) do
      connector.field.call(self, query, &block)
    end
  end

  def self.fields(query, &block)
    @fields = { query: query, block: block }
  end

  def self.fields_call(binder)
    Multiple.bind(connector: connector, binder: binder, query: @fields[:query], block: @fields[:block]) if @fields
  end
end
