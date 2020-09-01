# frozen_string_literal: true

#
# xml
#
class Spidy::Connector::Xml
  include Spidy::Connector::StaticAccessor

  def call(url)
    fail 'URL is undefined' if url.blank?

    OpenURI.open_uri(url, "User-Agent" => @user_agent) do |body|
      yield Nokogiri::XML(body.read.gsub(/[\x00-\x09\x0B\x0C\x0E-\x1F\x7F]/, ''), url)
    end
  end

  def initialize(wait_time: nil, user_agent: nil)
    @user_agent = user_agent
  end
end
