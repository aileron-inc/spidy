# frozen_string_literal: true

#
# Direct resource ( not network resource  )
#
module Spidy::Connector::Direct
  def self.call(resource, &yielder)
    yielder.call(resource)
  end
end
