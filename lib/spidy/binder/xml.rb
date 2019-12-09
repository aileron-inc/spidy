# frozen_string_literal: true

#
# Bind xml and convert to object
#
class Spidy::Binder::Xml
  class_attribute :names, default: []
  attr_reader :xml, :source, :url

  def initialize(xml, url: nil)
    @xml = xml
    @url = url
    @source = xml.to_s
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
