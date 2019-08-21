# frozen_string_literal: true

#
# looper
#
class Spidy::Looper
  def initialize(resource, binder, loop_block)
    @resource = resource
    @binder = binder
    @loop_block = loop_block
  end

  def call
    yielder = lambda do |element|
      result = @binder.new(element).result
      fail "#{element}\n\n#{result.errors.full_messages}" if result.invalid?

      yield result
    end
    @loop_block.call(@resource, yielder)
  end
end
