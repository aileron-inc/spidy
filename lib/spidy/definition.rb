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

  def user_agent(user_agent)
    @user_agent = user_agent
  end

  def wait_time(wait_time)
    @wait_time = wait_time
  end

  def socks_proxy(host, port)
    @socks_proxy = { host: host, port: port }
  end

  def each(source = nil, name: :default, &yielder)
    name = name.presence || :default
    spidy = @namespace[:"#{name}_spider"]
    fail "undefined spidy [#{name}]" if spidy.nil?

    spidy.call(source, &yielder)
  end

  def spider(name = :default, connector: nil, as: nil, &define_block)
    @namespace ||= {}
    connector = Spidy::Connector.get(connector || as, wait_time: @wait_time, user_agent: @user_agent, socks_proxy: @socks_proxy)
    @namespace[:"#{name}_spider"] = proc do |source, &yielder|
      define_block.call(yielder, connector, source)
    end
  end

  def define(name = :default, connector: nil, as: nil, &define_block)
    connector = Spidy::Connector.get(connector || as, wait_time: @wait_time, user_agent: @user_agent, socks_proxy: @socks_proxy)
    binder_base = Spidy::Binder.const_get(as.to_s.classify)
    @namespace ||= {}
    @namespace[:"#{name}_scraper"] = Class.new(Spidy::DefineObject) do
      extend binder_base
      class_eval(&define_block)
      define_singleton_method(:call) do |source, &yielder|
        yielder = lambda { |result| break result } if yielder.nil?
        connection_yielder = lambda do |page|
          yielder.call(new(page, source))
        end
        connector.call(source, &connection_yielder)
      end
    end
  end
end
