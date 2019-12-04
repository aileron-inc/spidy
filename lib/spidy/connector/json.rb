# frozen_string_literal: true

#
# OpenURI to JSON.parse
#
module Spidy::Connector::Json
  def self.call(url, &yielder)
    fail 'url is not specified' if url.blank?
    OpenURI.open_uri(url) { |body| yielder.call(JSON.parse(body.read, symbolize_names: true)) }
  end
end
