# frozen_string_literal: true

#
# Mechanize wrapper
#
module Spidy::Connector::Html
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

  @logger = proc { |values| STDERR.puts(values.to_json) }
  @agent = Mechanize.new
  @agent.user_agent = Spidy::Connector::USER_AGENT

  class << self
    attr_reader :agent
    attr_accessor :logger

    def call(url, encoding: nil, retry_count: 5, &yielder)
      fail 'url is not specified' if url.blank?
      if encoding
        agent.default_encoding = encoding
        agent.force_default_encoding = true
      end
      logger.call('connnector.get': url, 'connnector.accessed': Time.current)
      get(url, retry_count, yielder)
    end

    private

    def get(url, retry_count, yielder)
      connect(url, retry_count, yielder)
    rescue Retry => e
      logger.call('retry.accessed': Time.current,
                  'retry.uri': url,
                  'retry.response_code': e.response_code,
                  'retry.rest_count': retry_count)

      @agent = Mechanize.new
      @agent.user_agent = Spidy::Connector::USER_AGENT

      retry_count -= 1
      if retry_count.positive?
        sleep e.wait_time
        retry
      end
      raise e
    end

    def connect(url, retry_count, yielder)
      result = nil
      agent.get(url) do |page|
        fail Retry, page: page, wait_time: 5 if page.title == 'Sorry, unable to access page...'

        result = yielder.call(page)
      end
      result
    rescue Mechanize::ResponseCodeError => e
      raise Retry, error: e if e.response_code == '429'
      raise e
    end

  end
end
