# frozen_string_literal: true

#
# xml
#
module Spidy::Connector::Xml
  def self.call(url)
    fail 'URL is undefined' if url.blank?

    xml = OpenURI.open_uri(url).read.gsub(/[\x00-\x09\x0B\x0C\x0E-\x1F\x7F]/, '')
    yield Nokogiri::XML(xml, url)
  end
end
