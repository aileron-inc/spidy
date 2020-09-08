# frozen_string_literal: true

#
# Direct resource ( not network resource  )
#
class Spidy::Connector::Direct
  def call(resource, &yielder)
    yielder.call(resource)
  end

  def initialize(wait_time: nil, user_agent: nil, logger: nil)
  end
end
