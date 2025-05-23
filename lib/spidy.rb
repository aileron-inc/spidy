require_relative 'spidy/version'
require 'active_support/all'
require 'mechanize'
require 'open-uri'
require 'socksify'
require 'tor'

#
# web spider dsl engine
#
module Spidy
  extend ActiveSupport::Autoload
  autoload :Shell
  autoload :CommandLine
  autoload :Console
  autoload :Definition
  autoload :DefinitionFile
  autoload :DefinitionObject
  autoload :Binder
  autoload :Connector

  def self.shell(filepath = nil)
    Spidy::Shell.new(filepath)
  end

  def self.open(filepath)
    Spidy::DefinitionFile.open(filepath).spidy
  end

  def self.define(&)
    spidy = Module.new do
      class_eval do
        extend ::Spidy::Definition
        module_eval(&)
      end
    end
    spidy.instance_eval do
      undef :spider
      undef :define
      undef :wait_time
      undef :user_agent
      undef :socks_proxy
    end
    spidy
  end
end
