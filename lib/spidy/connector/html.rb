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
    def call(url, encoding: nil, &yielder)
      if encoding
        @agent.default_encoding = encoding
        @agent.force_default_encoding = true
      end
      get(url, yielder)
    end

    def get(url, yielder)
      @agent.get(url, &yielder)
    rescue Mechanize::ResponseCodeError => e
      case e.response_code
      when '429'
        sleep 2
        @agent.get(url, &yielder)
      else
        raise e
      end
    end
  end
end
