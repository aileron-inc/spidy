#
# OpenURI to JSON.parse
#
class Spidy::Connector::Json
  include Spidy::Connector::StaticAccessor

  attr_reader :logger

  def initialize(user_agent:)
    @user_agent = user_agent
  end

  def call(url, &)
    fail 'url is not specified' if url.blank?
    connect(url, &)
  end

  def connect(url)
    OpenURI.open_uri(url, 'User-Agent' => @user_agent) { |body| yield JSON.parse(body.read, symbolize_names: true) }
  rescue OpenURI::HTTPError => e
    raise Spidy::Connector::Retry.new(error: e, response_code: e.io.status[0])
  end
end
