#
# xml
#
class Spidy::Connector::Xml
  include Spidy::Connector::StaticAccessor

  def call(url, &)
    fail 'URL is undefined' if url.blank?

    connect(url, &)
  end

  def connect(url)
    OpenURI.open_uri(url, 'User-Agent' => @user_agent) do |body|
      yield Nokogiri::XML(body.read.gsub(/[\x00-\x09\x0B\x0C\x0E-\x1F\x7F]/, ''), url)
    end
  rescue OpenURI::HTTPError => e
    raise Spidy::Connector::Retry.new(error: e, response_code: e.io.status[0])
  end

  def initialize(user_agent:)
    @user_agent = user_agent
  end
end
