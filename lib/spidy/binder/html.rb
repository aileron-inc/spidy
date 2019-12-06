# frozen_string_literal: true

#
# Bind html and convert to object
#
module Spidy::Binder::Html
  #
  # Describe the definition to get the necessary elements from the resource object
  #
  class Resource
    class_attribute :names, default: []
    attr_reader :html

    def initialize(html)
      @html = html
    end

    def to_s
      to_h.to_json
    end

    def url
      html.uri.to_s
    end

    def to_h
      names.map { |name| [name, send(name)] }.to_h
    end

    def self.let(name, query = nil, &block)
      names << name
      define_method(name) do
        return html.at(query)&.text if block.nil?
        return instance_exec(&block) if query.blank?

        instance_exec(html.search(query), &block)
      rescue NoMethodError => e
        raise "#{html.uri} ##{name} => #{e.message}"
      end
    end
  end

  def self.call(html, define_block)
    binder = Class.new(Resource) { instance_exec(&define_block) }
    yield binder.new(html)
  end
end
