# frozen_string_literal: true

#
# Mechanize wrapper
#
class Spidy::Connector::Html
  include Spidy::Connector::StaticAccessor

  def initialize(user_agent:)
    @agent = Mechanize.new
    @user_agent = user_agent
    @agent.user_agent = user_agent
  end

  attr_reader :agent

  def call(url, encoding: nil, retry_count: 5, &yielder)
    fail 'url is not specified' if url.blank?
    if encoding
      agent.default_encoding = encoding
      agent.force_default_encoding = true
    end
    connect(url, retry_count, yielder)
  end

  def refresh!
    @agent = Mechanize.new
    @agent.user_agent = @user_agent
  end

  private

  def connect(url, retry_count, yielder)
    result = nil
    agent.get(url) do |page|
      fail Spidy::Connector::Retry, object: page, response_code: page.try(:response_code) if page.title == 'Sorry, unable to access page...'

      result = yielder.call(page)
    end
    result
  rescue Mechanize::ResponseCodeError => e
    raise Spidy::Connector::Retry, error: e, response_code: e.try(:response_code) if e.response_code == '429'
    raise Spidy::Connector::Retry, error: e, response_code: e.try(:response_code) if e.response_code == '502'
    raise Spidy::Connector::Retry, error: e, response_code: e.try(:response_code)
  end
end
