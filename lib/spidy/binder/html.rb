# frozen_string_literal: true

#
# Bind html and convert to object
#
class Spidy::Binder::Html
  class << self
    attr_reader :attribute_names

    def let(name, query = nil, &block)
      @attribute_names ||= []
      @attribute_names << name
      define_method(name) do
        return html.at(query)&.text if block.nil?
        return instance_exec(&block) if query.blank?

        instance_exec(html.at(query), &block)
      rescue NoMethodError => e
        raise "#{html.uri} ##{name} => #{e.message}"
      end
    end
  end

  attr_reader :html, :url
  alias_method :resource, :html

  def initialize(html, url: nil)
    @url = url
    @html = html
  end

  def to_s
    to_h.to_json
  end

  def to_h
    self.class.attribute_names.map { |name| [name, send(name)] }.to_h
  end
end
