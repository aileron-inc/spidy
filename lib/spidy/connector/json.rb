# frozen_string_literal: true

#
# OpenURI to JSON.parse
#
class Spidy::Connector::Json
  include Spidy::Connector::StaticAccessor

  attr_reader :logger

  def initialize(wait_time: nil, user_agent: nil, logger: nil)
    @wait_time = wait_time
    @user_agent = user_agent
    @logger = logger
  end

  def call(url, &block)
    fail 'url is not specified' if url.blank?
    connect(url, &block)
  end

  def connect(url, retry_count: 5)
    OpenURI.open_uri(url, "User-Agent" => @user_agent) { |body| yield JSON.parse(body.read, symbolize_names: true) }
  rescue OpenURI::HTTPError => e
    logger.call('retry.accessed': Time.current,
                'retry.uri': url,
                'retry.response_code': e.message,
                'retry.rest_count': retry_count)

    retry_count -= 1
    if retry_count.positive?
      sleep @wait_time
      retry
    end
    raise e
  end
end
