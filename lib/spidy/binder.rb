# frozen_string_literal: true

#
# Bind resource received from the connection to the result object
#
module Spidy::Binder
  extend ActiveSupport::Autoload
  autoload :Json
  autoload :Html
  autoload :Xml

  class Caller
    def initialize(spidy, binder)
      @spidy = spidy
      @binder = binder
    end

    def call(source, url: nil, define: nil)
      yield Class.new(@binder, &define).new(@spidy, source, url)
    end
  end

  def self.get(spidy, value)
    return Caller.new(spidy, const_get(value.to_s.classify)) if name.is_a?(String) || name.is_a?(Symbol)

    value
  end
end
