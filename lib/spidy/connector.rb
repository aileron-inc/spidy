# frozen_string_literal: true

#
# This class is responsible for actually making a network connection and downloading hypertext
#
module Spidy::Connector
  extend ActiveSupport::Autoload
  autoload :Direct
  autoload :Html
  autoload :Json
  autoload :Xml

  USER_AGENT = [
    'Mozilla/5.0',
    '(Macintosh; Intel Mac OS X 10_12_6)',
    'AppleWebKit/537.36',
    '(KHTML, like Gecko)',
    'Chrome/64.0.3282.186',
    'Safari/537.36'
  ].join(' ')

  def self.get(value)
    return const_get(value.to_s.classify) if value.is_a?(String) || value.is_a?(Symbol)

    value
  end
end
