# frozen_string_literal: true

#
# Class representing a website defined by DSL
#
class Spidy::Definition
  class_attribute :domain
  class_attribute :spiders, default: {}
  class_attribute :scrapers, default: {}
  class_attribute :output, default: ->(result) { STDOUT.puts(result.attributes.to_json) }

  def output(&block)
    self.output = block
  end

  # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
  class << self
    def spider(name, start_url = nil, encoding: nil, as: :html, &block)
      connector_class = Spidy::Connector.const_get(as.to_s.classify)
      connector = connector_class.new(start_url: start_url, encoding: encoding)
      spider = Spidy::Spider.new(&block)
      spider_class = Class.new do
        define_singleton_method(:connector) { connector }
        define_singleton_method(:call) do |url = start_url, &spider_block|
          connector.call(url) do |resource|
            spider.call(resource, &spider_block)
          end
        end
      end
      const_set("#{name}_spider".classify, spider_class)
      spiders[name] = spider_class
    end

    def scraper(name, options, &block)
      if options[:loop]
        loop_scraper(name, options, &block)
      else
        normal_scraper(name, **options, &block)
      end
    end

    private

    def loop_scraper(name, options, &block)
      options = { as: :html, start_url: nil, encoding: nil, loop: nil }.merge(options)
      result_class = Class.new(Spidy::Result)

      # connector
      connector_class = Spidy::Connector.const_get(options[:as].to_s.classify)
      connector = connector_class.new(encoding: options[:encoding])

      namespace = Class.new do
        binder = Class.new(Spidy::Binder) do
          define_singleton_method(:connector) { connector }
          define_singleton_method(:result_class) { result_class }
          define_method(:connector) { connector }
          instance_exec(&block)
        end
        define_singleton_method(:call) do |url = options[:start_url], &yielder|
          connector.call(url) do |resource|
            looper = Spidy::Looper.new(resource, binder, options[:loop])
            looper.call(&yielder)
          end
        end
      end
      const_set("#{name}_scraper".classify, namespace)
      scrapers[name] = namespace
    end

    def normal_scraper(name, encoding: nil, as: :html, &block)
      # result
      result_class = Class.new(Spidy::Result)

      # connector
      connector_class = Spidy::Connector.const_get(as.to_s.classify)
      connector = connector_class.new(encoding: encoding)

      # namespace
      namespace = Class.new do
        binder = Class.new(Spidy::Binder) do
          define_singleton_method(:connector) { connector }
          define_singleton_method(:result_class) { result_class }
          define_method(:connector) { connector }
          instance_exec(&block)
        end
        define_singleton_method(:bind) do |url|
          connector.call(url) do |resource|
            binder.new(resource)
          end
        end
        define_singleton_method(:call) do |url, &output|
          result = bind(url).result
          fail "#{url}\n#{result.errors.full_messages}" if result.invalid?

          output.call(result)
        end
      end
      const_set("#{name}_scraper".classify, namespace)
      scrapers[name] = namespace
    end
  end
  # rubocop:enable Metrics/MethodLength, Metrics/AbcSize
end
