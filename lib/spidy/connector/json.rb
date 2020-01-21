# frozen_string_literal: true

#
# OpenURI to JSON.parse
#
module Spidy::Connector::Json
  def self.call(url)
    fail 'url is not specified' if url.blank?
    OpenURI.open_uri(url, "User-Agent" => Spidy::Connector::USER_AGENT) { |body| yield JSON.parse(body.read, symbolize_names: true) }
  end
end
