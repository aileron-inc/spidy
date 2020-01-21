# frozen_string_literal: true

#
# Bind xml and convert to object
#
class Spidy::Binder::Xml
  class << self
    attr_reader :names
    @names = []

    def self.let(name, query = nil, &block)
      @names << name
      define_method(name) do
        return xml.at(query)&.text if block.nil?
        return instance_exec(&block) if query.blank?

        instance_exec(xml.at(query), &block)
      rescue NoMethodError => e
        raise "#{xml} ##{name} => #{e.message}"
      end
    end
  end

  attr_reader :xml, :url

  def initialize(xml, url: nil)
    @xml = xml
    @url = url
  end

  def to_s
    to_h.to_json
  end

  def to_h
    self.class.names.map { |name| [name, send(name)] }.to_h
  end
end
