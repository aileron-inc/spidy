#
# Spider
#
class Spidy::Spider
  def initialize(&)
    define_singleton_method(:bind, &)
  end

  def call(resource)
    yielder = lambda do |url|
      yield url if block_given?
    end
    bind(resource, yielder)
  end
end
