# frozen_string_literal: true

#
# Direct resource ( not network resource  )
#
class Spidy::Connector::Direct
  def call(resource, &yielder)
    yielder.call(resource)
  end

  def initialize(user_agent:)
  end
end
