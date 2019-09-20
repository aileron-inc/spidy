# frozen_string_literal: true

#
# OpenURI to JSON.parse
#
module Spidy::Connector::Json
  def self.call(url, &yielder)
    OpenURI.open_uri(url) { |body| yielder.call(JSON.parse(body.read)) }
  end
end
