# frozen_string_literal: true

#
# Class representing a website defined by DSL
#
module Spidy::Definition
  def call(name = :default, url: nil, stream: nil, err: nil, &output)
    name = name.presence || :default
    spidy = @namespace[:"#{name}_scraper"]
    fail "undefined spidy [#{name}]" if spidy.nil?

    exec(spidy, url: url, stream: stream, err: err, &output)
  end

  def each(name = :default, url: nil, stream: nil, err: nil, &output)
    name = name.presence || :default
    spidy = @namespace[:"#{name}_spider"]
    fail "undefined spidy [#{name}]" if spidy.nil?

    exec(spidy, url: url, stream: stream, err: err, &output)
  end

  def spider(name = :default, connector: nil, as: nil)
    @namespace ||= {}
    connector = Spidy::Connector.get(as || connector) || connector
    @namespace[:"#{name}_spider"] = proc do |url, &yielder|
      yield(yielder, connector, url)
    end
  end

  def define(name = :default, connector: nil, binder: nil, as: nil, &define_block)
    @namespace ||= {}
    connector = Spidy::Connector.get(connector || as)
    binder = Spidy::Binder.get(binder || as)
    @namespace[:"#{name}_scraper"] = define_proc(connector, binder, define_block)
  end

  private

  def exec(spidy, url: nil, stream: nil, err: nil, &output)
    return spidy.call(url, &output) if stream.nil?

    stream.each do |value|
      spidy.call(value.strip, &output)
    rescue StandardError => e
      raise e if err.nil?

      err.call(e, value.strip)
    end
  end

  def define_proc(connector, binder, define_block)
    proc do |url, &yielder|
      fail 'block is not specified' if yielder.nil?

      connection_yielder = lambda do |resource|
        binder.call(resource, define_block) { |object| yielder.call(object) }
      end
      connector.call(url, &connection_yielder)
    end
  end
end
