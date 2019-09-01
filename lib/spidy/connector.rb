# frozen_string_literal: true

#
# This class is responsible for actually making a network connection and downloading hypertext
#
module Spidy::Connector
  extend ActiveSupport::Autoload
  autoload :Html
  autoload :Json

  def self.get(name)
    return unless name.is_a?(String) || name.is_a?(Symbol)

    const_get(name.to_s.classify)
  end
end
