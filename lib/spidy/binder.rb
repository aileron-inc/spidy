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
    def initialize(binder)
      @binder = binder
    end

    def call(source, url: nil, define: nil)
      yield Class.new(@binder, &define).new(source, url: url)
    end
  end

  def self.get(value)
    return Caller.new(const_get(value.to_s.classify)) if name.is_a?(String) || name.is_a?(Symbol)

    value
  end
end
