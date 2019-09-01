# frozen_string_literal: true

#
# Class representing a website defined by DSL
#
class Spidy::Definition
  class_attribute :namespace, default: {}
  class_attribute :spiders, default: {}

  class << self
    def define(name, connector: nil, binder: nil, as: nil, &define_block)
      connector = Spidy::Connector.get(as || connector) || connector
      binder = Spidy::Binder.get(as || binder) || binder
      namespace[name] = proc do |url, &yielder|
        connection_yielder = lambda do |resource|
          binder.call(resource, define_block) do |object|
            yielder.call(object)
          end
        end
        connector.call(url, &connection_yielder)
      end
    end

    def spider(name, connector: nil, as: nil)
      connector = Spidy::Connector.get(as || connector) || connector
      spiders[name] = proc do |url, &yielder|
        yield(yielder, connector, url)
      end
    end
  end
end
