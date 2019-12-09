# frozen_string_literal: true

#
# Bind resource received from the connection to the result object
#
module Spidy::Binder
  extend ActiveSupport::Autoload
  autoload :Json
  autoload :Html
  autoload :Xml

  module Base
    def self.call(html, url: nil, define: nil)
      binder = Class.new(const_get(:Resource)) { instance_exec(&define) }
      yield binder.new(html, url: url)
    end
  end

  class Caller
    def initialize(binder)
      @binder = binder
    end

    def call(source, url: nil, define: nil)
      binder = Class.new(@binder) { instance_exec(&define) }
      yield binder.new(source, url: url)
    end
  end

  def self.get(value)
    return Caller.new(const_get(value.to_s.classify)) if name.is_a?(String) || name.is_a?(Symbol)

    value
  end
end
