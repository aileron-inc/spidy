# frozen_string_literal: true

#
# This class is responsible for actually making a network connection and downloading hypertext
#
module Spidy::Connector
  extend ActiveSupport::Autoload
  autoload :Html
  autoload :Json
  autoload :Xml

  def self.get(value)
    return const_get(value.to_s.classify) if value.is_a?(String) || value.is_a?(Symbol)

    value
  end
end
