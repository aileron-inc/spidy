# frozen_string_literal: true

#
# Class representing a website defined by DSL
#
class Spidy::Definition
  class_attribute :namespace, default: {}
  class_attribute :spiders, default: {}

  class << self
    def spider(name = :default, connector: nil, as: nil)
      connector = Spidy::Connector.get(as || connector) || connector
      spiders[name] = proc do |url, &yielder|
        yield(yielder, connector, url)
      end
    end

    def define(name = :default, connector: nil, binder: nil, as: nil, &define_block)
      connector = Spidy::Connector.get(as || connector) || connector
      binder = Spidy::Binder.get(as || binder) || binder
      namespace[name] = define_proc(connector, binder, define_block)
    end

    private

    def define_proc(connector, binder, define_block)
      proc do |url, &yielder|
        fail 'invalid argument [Required url / block]' if url.blank? && yielder.nil?

        connection_yielder = lambda do |resource|
          binder.call(resource, define_block) { |object| yielder.call(object) }
        end
        connector.call(url, &connection_yielder)
      end
    end
  end
end
