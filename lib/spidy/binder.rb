# frozen_string_literal: true

#
# Bind resource received from the connection to the result object
#
module Spidy::Binder
  extend ActiveSupport::Autoload
  autoload :Json
  autoload :Html
  autoload :Xml

  class Error < StandardError
  end

  class Caller
    def initialize(spidy, binder)
      @spidy = spidy
      @binder = binder
    end

    def call(source, url: nil, define: nil, define_name: nil)
      yield Class.new(@binder, &define).new(define_name, @spidy, source, url)
    end
  end

  class Base
    class << self
      attr_reader :attribute_names
    end

    attr_reader :resource, :url

    def initialize(define_name, spidy, resource, url)
      @define_name = define_name
      @spidy = spidy
      @resource = resource
      @url = url
    end

    def to_s
      to_h.to_json
    end

    def to_h
      binding.pry
      self.class.attribute_names.map { |name| [name, send(name)] }.to_h
    end
  end


  def self.get(spidy, value)
    return Caller.new(spidy, const_get(value.to_s.classify)) if name.is_a?(String) || name.is_a?(Symbol)

    value
  end
end
