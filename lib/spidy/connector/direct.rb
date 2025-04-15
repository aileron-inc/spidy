#
# Direct resource ( not network resource  )
#
class Spidy::Connector::Direct
  def call(resource)
    if block_given?
      yield resource
    else
      resource
    end
  end

  def initialize(user_agent:); end
end
