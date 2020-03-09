# frozen_string_literal: true

#
# Bind xml and convert to object
#
class Spidy::Binder::Xml < Spidy::Binder::Base
  def self.let(name, query = nil, &block)
    @attribute_names ||= []
    @attribute_names << name

    return define_method(name) { xml.at(query)&.text } if block.nil?

    define_method(name) do
      if query.present?
        instance_exec(xml.at(query), &block)
      else
        instance_exec(&block)
      end
    rescue StandardError => e
      fail Spidy::Binder::Error, "spidy(#{@define_name})##{name} => #{e.message}"
    end
  end

  alias_method :xml, :resource
end
