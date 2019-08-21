# frozen_string_literal: true

#
# xml
#
class Spidy::Connector::Xml
  class_attribute :field, default: (lambda { |object, query, optional: false, &block|
    return object.instance_exec(object.resource, &block) if query.nil?

    node = object.resource.search(query)
    return if optional && node.empty?

    fail "Could not be located #{query}" if node.empty?
    return node.first.text if block.nil?

    object.instance_exec(node, &block)
  })

  def initialize(start_url: nil, encoding: nil)
    @start_url = start_url
    @encoding = encoding
  end

  def call(url = @start_url)
    fail 'URL is undefined' if url.blank?

    xml =
      Nokogiri::XML(OpenURI.open_uri(url).read.gsub(/[\x00-\x09\x0B\x0C\x0E-\x1F\x7F]/, ''))
    yield xml
  end
end
