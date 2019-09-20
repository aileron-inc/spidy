# frozen_string_literal: true

#
# Mechanize wrapper
#
module Spidy::Connector::Html
  USER_AGENT = [
    'Mozilla/5.0',
    '(Macintosh; Intel Mac OS X 10_12_6)',
    'AppleWebKit/537.36',
    '(KHTML, like Gecko)',
    'Chrome/64.0.3282.186',
    'Safari/537.36'
  ].join(' ')

  @agent = Mechanize.new
  @agent.user_agent = USER_AGENT

  class << self
    attr_reader :agent

    def call(url, encoding: nil, retry_count: 3, &yielder)
      if encoding
        @agent.default_encoding = encoding
        @agent.force_default_encoding = true
      end
      get(url, retry_count, yielder)
    end

    private

    def get(url, retry_count, yielder)
      @agent.get(url, &yielder)
    rescue Mechanize::ResponseCodeError => e
      retry_count -= 1
      case e.response_code
      when '429'
        sleep 2
        retry if retry_count
      else
        raise e
      end
    end
  end
end
