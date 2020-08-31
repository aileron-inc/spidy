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

  #
  # retry class
  #
  class Retry < StandardError
    attr_reader :page
    attr_reader :response_code
    attr_reader :wait_time

    def initialize(wait_time: 2, page: nil, error: nil)
      @page = page
      @wait_time = wait_time
      @response_code = error.try(:response_code) || page.try(:response_code)
    end
  end

  #
  # default user agent
  #
  USER_AGENT = [
    'Mozilla/5.0',
    '(Macintosh; Intel Mac OS X 10_12_6)',
    'AppleWebKit/537.36',
    '(KHTML, like Gecko)',
    'Chrome/64.0.3282.186',
    'Safari/537.36'
  ].join(' ')

  #
  # get connection handller
  #
  def self.get(value, wait_time: nil, user_agent: nil, socks_proxy: nil)
    return value if value.respond_to?(:call)

    connector = const_get(value.to_s.classify).new(wait_time: wait_time || 5, user_agent: user_agent || USER_AGENT)
    return connector if socks_proxy.nil?

    lambda do |url, &block|
      Socksify::proxy(socks_proxy[:host], socks_proxy[:port]) do
        connector.call(url, &block)
      end
    end
  end
end
