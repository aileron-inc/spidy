# frozen_string_literal: true

#
# Bind xml and convert to object
#
module Spidy::Binder::Xml
  #
  # Describe the definition to get the necessary elements from the resource object
  #
  class Resource
    class_attribute :names, default: []
    attr_reader :xml

    def initialize(xml)
      @xml = xml
    end

    def to_s
      to_h.to_json
    end

    def to_h
      names.map { |name| [name, send(name)] }.to_h
    end

    def self.let(name, query = nil, &block)
      names << name
      define_method(name) do
        return xml.at(query)&.text if block.nil?
        return instance_exec(&block) if query.blank?

        instance_exec(xml.search(query), &block)
      rescue NoMethodError => e
        raise "#{xml} ##{name} => #{e.message}"
      end
    end
  end

  def self.call(xml, define_block)
    binder = Class.new(Resource) { instance_exec(&define_block) }
    yield binder.new(xml)
  end
end
