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

  def self.call(url, encoding: nil, &yielder)
    agent = Mechanize.new
    if encoding
      agent.default_encoding = encoding
      agent.force_default_encoding = true
    end
    agent.user_agent = USER_AGENT
    agent.get(url, &yielder)
  end
end
