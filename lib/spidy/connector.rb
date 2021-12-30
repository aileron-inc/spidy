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

  DEFAULT_WAIT_TIME = 5

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
  # error output logger
  #
  DEFAULT_LOGGER = proc { |values| warn(values.to_json) }

  #
  # static method
  #
  module StaticAccessor
    extend ActiveSupport::Concern
    class_methods do
      def call(url, wait_time: 5, logger: Spidy::Connector::DEFAULT_LOGGER, user_agent: Spidy::Connector::USER_AGENT, &block)
        ::Spidy::Connector::RetryableCaller.new(new(user_agent: user_agent), wait_time: wait_time, logger: logger).call(
          url, &block
        )
      end
    end
  end

  #
  # retry class
  #
  class Retry < StandardError
    attr_reader :object, :response_code, :error

    def initialize(object: nil, error: nil, response_code: nil)
      @object = object
      @response_code = response_code
      @error = error
      super(error)
    end
  end

  #
  # retry
  #
  class RetryableCaller
    attr_reader :origin_connector

    def initialize(connector, logger:, wait_time:)
      @origin_connector = connector
      @logger = logger
      @wait_time = wait_time
      @retry_attempt_count = 5
    end

    def call(url, &block)
      block ||= ->(result) { break result }
      connect(url, &block)
    end

    def connect(url, retry_attempt_count: @retry_attempt_count, &block)
      @logger.call('connnector.get': url, 'connnector.accessed': Time.current)
      @origin_connector.call(url, &block)
    rescue Spidy::Connector::Retry => e
      @logger.call('retry.accessed': Time.current,
                   'retry.uri': url,
                   'retry.response_code': e.response_code,
                   'retry.attempt_count': retry_attempt_count)

      retry_attempt_count -= 1
      if retry_attempt_count.positive?
        sleep @wait_time
        @origin_connector.refresh! if @origin_connector.respond_to?(:refresh!)
        retry
      end
      raise e.error
    end
  end

  #
  # tor proxy
  #
  class TorConnector
    attr_reader :connector, :socks_proxy

    def initialize(connector, socks_proxy)
      @connector = connector
      @socks_proxy = socks_proxy
    end

    def call(url, &block)
      Socksify.proxy(socks_proxy[:host], socks_proxy[:port]) do
        connector.call(url, &block)
      end
    end

    def try_connection?
      try_connection!
      true
    rescue Errno::ECONNREFUSED
      false
    end

    def try_connection!
      Tor::Controller.new(host: @socks_proxy[:host], port: @socks_proxy[:port]).close
    end
  end

  def self.get(value, wait_time: nil, user_agent: nil, socks_proxy: nil, logger: nil)
    user_agent ||= USER_AGENT
    logger ||= DEFAULT_LOGGER
    wait_time ||= DEFAULT_WAIT_TIME

    connector = get_connector(value, user_agent: user_agent, socks_proxy: socks_proxy)
    return connector if connector.is_a?(Spidy::Connector::Direct)

    RetryableCaller.new(connector, wait_time: wait_time, logger: logger)
  end

  #
  # get connection handller
  #
  def self.get_connector(value, user_agent: nil, socks_proxy: nil)
    return value if value.respond_to?(:call)

    connector = const_get(value.to_s.classify).new(user_agent: user_agent)
    fail "Not defined connnector[#{value}]" if connector.nil?
    return connector if socks_proxy.nil?

    TorConnector.new(connector, socks_proxy)
  end
end
