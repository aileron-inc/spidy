# frozen_string_literal: true

#
# Mechanize wrapper
#
class Spidy::Connector::Html
  def initialize(wait_time:, user_agent:, logger: nil)
    @wait_time = wait_time
    @logger = logger || proc { |values| STDERR.puts(values.to_json) }
    @agent = Mechanize.new
    @user_agent = user_agent
    @agent.user_agent = user_agent
  end

  attr_reader :agent
  attr_reader :logger

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
  rescue Spidy::Connector::Retry => e
    logger.call('retry.accessed': Time.current,
                'retry.uri': url,
                'retry.response_code': e.response_code,
                'retry.rest_count': retry_count)

    @agent = Mechanize.new
    @agent.user_agent = @user_agent

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
      fail Spidy::Connector::Retry, page: page, wait_time: @wait_time if page.title == 'Sorry, unable to access page...'

      result = yielder.call(page)
    end
    result
  rescue Mechanize::ResponseCodeError => e
    raise Spidy::Connector::Retry, error: e, wait_time: @wait_time if e.response_code == '429'
    raise Spidy::Connector::Retry, error: e, wait_time: @wait_time if e.response_code == '502'
    raise e
  end
end
