# frozen_string_literal: true

#
# OpenURI to JSON.parse
#
class Spidy::Connector::Json
  def initialize(wait_time: nil, user_agent: nil)
    @user_agent = user_agent
  end

  def call(url, &block)
    fail 'url is not specified' if url.blank?
    connect(url, &block)
  end

  def connect(url)
    OpenURI.open_uri(url, "User-Agent" => @user_agent) { |body| yield JSON.parse(body.read, symbolize_names: true) }
  end
end
