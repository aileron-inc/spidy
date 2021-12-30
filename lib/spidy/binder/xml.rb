# frozen_string_literal: true

#
# Bind xml and convert to object
#
module Spidy::Binder::Xml
  def let(name, query = nil, &block)
    @attribute_names ||= []
    @attribute_names << name

    return define_method(name) { xml.at(query)&.text&.strip } if block.nil?

    define_method(name) do
      if query.present?
        instance_exec(xml.at(query), &block)
      else
        instance_exec(&block)
      end
    rescue StandardError => e
      raise Spidy::Binder::Error, "spidy(#{@define_name})##{name} => #{e.message}"
    end
  end

  def self.extended(obj)
    obj.alias_method :xml, :resource
  end
end
