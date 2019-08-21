# frozen_string_literal: true

#
# Mechanize wrapper
#
class Spidy::Connector::Html
  class_attribute :field, default: (lambda { |object, query, &block|
    node = object.resource.search(query)
    fail "Could not be located #{query}" if node.nil?
    return node.first.text if block.nil?

    object.instance_exec(node, &block)
  })

  USER_AGENT = [
    'Mozilla/5.0',
    '(Macintosh; Intel Mac OS X 10_12_6)',
    'AppleWebKit/537.36',
    '(KHTML, like Gecko)',
    'Chrome/64.0.3282.186',
    'Safari/537.36'
  ].join(' ')

  attr_reader :start_url
  attr_reader :agent

  def initialize(start_url: nil, encoding: nil)
    @start_url = start_url
    @agent = Mechanize.new
    if encoding
      @agent.default_encoding = encoding
      @agent.force_default_encoding = true
    end
    @agent.user_agent = USER_AGENT
  end

  def call(url = @start_url, &block)
    fail 'URL is undefined' if url.blank?

    agent.get(url, &block)
  end
end
