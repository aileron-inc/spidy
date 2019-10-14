# frozen_string_literal: true

#
# Bind resource received from the connection to the result object
#
module Spidy::Binder
  extend ActiveSupport::Autoload
  autoload :Json
  autoload :Html
  autoload :Xml

  def self.get(value)
    return const_get(value.to_s.classify) if name.is_a?(String) || name.is_a?(Symbol)

    value
  end
end
