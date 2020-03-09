# frozen_string_literal: true

#
# Bind json and convert to object
#
class Spidy::Binder::Json < Spidy::Binder::Base
  def self.let(name, *query, &block)
    @attribute_names ||= []
    @attribute_names << name

    return define_method(name) { json.dig(*query) } if block.nil?

    define_method(name) do
      if query.present?
        instance_exec(json.dig(*query), &block)
      else
        instance_exec(&block)
      end
    rescue StandardError => e
      fail Spidy::Binder::Error, "spidy(#{@define_name})##{name} => #{e.message}"
    end
  end

  alias_method :json, :resource
end
