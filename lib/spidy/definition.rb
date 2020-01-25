# frozen_string_literal: true

#
# Class representing a website defined by DSL
#
module Spidy::Definition
  def namespace
    @namespace
  end

  def call(source = nil, name: :default, &yielder)
    name = name.presence || :default
    spidy = @namespace[:"#{name}_scraper"]
    fail "undefined spidy [#{name}]" if spidy.nil?

    spidy.call(source, &yielder)
  end

  def each(source = nil, name: :default, &yielder)
    name = name.presence || :default
    spidy = @namespace[:"#{name}_spider"]
    fail "undefined spidy [#{name}]" if spidy.nil?

    spidy.call(source, &yielder)
  end

  def spider(name = :default, connector: nil, as: nil, &define_block)
    @namespace ||= {}
    connector = Spidy::Connector.get(connector || as)
    @namespace[:"#{name}_spider"] = proc do |source, &yielder|
      define_block.call(yielder, connector, source)
    end
  end

  def define(name = :default, connector: nil, binder: nil, as: nil, &define_block)
    @namespace ||= {}
    connector = Spidy::Connector.get(connector || as)
    binder = Spidy::Binder.get(self, binder || as)
    @namespace[:"#{name}_scraper"] = define_proc(connector, binder, define_block)
  end

  private

  def define_proc(connector, binder, define_block)
    proc do |source, &yielder|
      fail 'block is not specified' if yielder.nil?

      connection_yielder = lambda do |page|
        binder.call(page, url: source, define: define_block) { |object| yielder.call(object) }
      end
      connector.call(source, &connection_yielder)
    end
  end
end
