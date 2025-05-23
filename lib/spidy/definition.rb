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

    if yielder
      spidy.call(source, &yielder)
    else
      Enumerator.new do |enumerate_yielder|
        spidy.call(source, &enumerate_yielder)
      end
    end
  end

  def spider(name = :default, connector: nil, as: nil)
    @namespace ||= {}
    connector = Spidy::Connector.get(connector || as, wait_time: @wait_time, user_agent: @user_agent,
                                                      socks_proxy: @socks_proxy)
    @namespace[:"#{name}_spider"] = proc do |source, &yielder|
      yield(yielder, connector, source)
    end
  end

  def define(name = :default, connector: nil, as: nil, &define_block)
    connector = Spidy::Connector.get(connector || as, wait_time: @wait_time, user_agent: @user_agent,
                                                      socks_proxy: @socks_proxy)
    binder_base = Spidy::Binder.const_get(as.to_s.classify)
    @namespace ||= {}
    @namespace[:"#{name}_scraper"] = Class.new(Spidy::DefinitionObject) do
      extend binder_base
      class_eval(&define_block)
      define_singleton_method(:call) do |source, &yielder|
        yielder = ->(result) { break result } if yielder.nil?
        connection_yielder = lambda do |page|
          yielder.call(new(page, source))
        end
        connector.call(source, &connection_yielder)
      end
    end
  end
end
