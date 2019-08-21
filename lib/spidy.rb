# frozen_string_literal: true

require 'spidy/version'
require 'active_support/all'
require 'active_model'
require 'mechanize'
require 'csv'
require 'open-uri'

#
# web spider dsl engine
#
module Spidy
  extend ActiveSupport::Autoload
  autoload :Shell
  autoload :Console
  autoload :Definition
  autoload :DefinitionFile
  autoload :Binder
  autoload :Spider
  autoload :Looper
  autoload :Connector
  autoload :Result

  const_set(:Crawler, Module.new) unless const_defined?(:Crawler)

  def self.console
    require 'pry'
    Pry.start(Spidy::Console.new)
  end

  def self.open(filepath)
    ::Spidy::DefinitionFile.open(filepath)
  end

  def self.define(name = nil, domain: nil, &block)
    crawler_definition = Class.new(::Spidy::Definition, &block)
    crawler_definition.domain = domain

    if name
      crawler_class_name = name.to_s.camelize
      Crawler.class_eval { remove_const(crawler_class_name) } if Crawler.const_defined?(crawler_class_name)
      Crawler.const_set(crawler_class_name, crawler_definition)
    end
    crawler_definition
  end
end
