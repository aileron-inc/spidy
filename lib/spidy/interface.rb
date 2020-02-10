# frozen_string_literal: true

#
# spidy interface
#
class Spidy::Interface
  delegate :call, :each, :namespace, to: :@spidy

  def initialize(spidy)
    @spidy = spidy
  end
end
