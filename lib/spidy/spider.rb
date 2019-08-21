# frozen_string_literal: true

#
# Spider
#
class Spidy::Spider
  def initialize(&block)
    define_singleton_method(:bind, &block)
  end

  def call(resource)
    yielder = lambda do |url|
      yield url if block_given?
    end
    bind(resource, yielder)
  end
end
