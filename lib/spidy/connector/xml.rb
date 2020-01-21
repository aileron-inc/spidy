# frozen_string_literal: true

#
# xml
#
module Spidy::Connector::Xml
  def self.call(url)
    fail 'URL is undefined' if url.blank?

    OpenURI.open_uri(url, "User-Agent" => Spidy::Connector::USER_AGENT) do |body|
      yield Nokogiri::XML(body.read.gsub(/[\x00-\x09\x0B\x0C\x0E-\x1F\x7F]/, ''), url)
    end
  end
end
