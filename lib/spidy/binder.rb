# frozen_string_literal: true

#
# Bind resource received from the connection to the result object
#
module Spidy::Binder
  extend ActiveSupport::Autoload
  autoload :Json
  autoload :Html

  def self.get(name)
    return unless name.is_a?(String) || name.is_a?(Symbol)

    const_get(name.to_s.classify)
  end
end
