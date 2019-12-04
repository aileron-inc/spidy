# frozen_string_literal: true

#
# Mechanize wrapper
#
module Spidy::Connector::Html
  #
  # retry class
  #
  class Retry < StandardError
    attr_reader :response_code
    attr_reader :wait_time

    def initialize(wait_time: 2, page: nil, error: nil)
      @wait_time = wait_time
      @response_code = error.try(:response_code) || page.try(:response_code)
    end
  end
  USER_AGENT = [
    'Mozilla/5.0',
    '(Macintosh; Intel Mac OS X 10_12_6)',
    'AppleWebKit/537.36',
    '(KHTML, like Gecko)',
    'Chrome/64.0.3282.186',
    'Safari/537.36'
  ].join(' ')

  @logger = proc { |values| STDERR.puts(values.map { |k, v| "#{k}:#{v}" }.join("\t")) }
  @agent = Mechanize.new
  @agent.user_agent = USER_AGENT

  class << self
    attr_reader :agent
    attr_accessor :logger

    def call(url, encoding: nil, retry_count: 3, &yielder)
      fail 'url is not specified' if url.blank?
      if encoding
        agent.default_encoding = encoding
        agent.force_default_encoding = true
      end
      logger.call('connnector.get': url, 'connnector.accessed': Time.current)
      get(url, retry_count, yielder)
    end

    private

    # rubocop:disable Metrics/MethodLength
    def get(url, retry_count, yielder)
      agent.get(url) do |page|
        fail Retry, page: page, wait_time: 5 if page.title == 'Sorry, unable to access page...'

        yielder.call(page)
      end
    rescue Mechanize::ResponseCodeError => e
      raise Retry, error: e if e.response_code == '429'
      raise e
    rescue Retry => e
      logger.call('retry.accessed': Time.current,
                  'retry.uri': url,
                  'retry.response_code': e.response_code,
                  'retry.rest_count': retry_count)

      @agent = Mechanize.new
      @agent.user_agent = USER_AGENT

      retry_count -= 1
      if retry_count.positive?
        sleep e.wait_time
        retry
      end
      raise e
    end
    # rubocop:enable Metrics/MethodLength
  end
end
