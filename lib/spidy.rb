# frozen_string_literal: true

require 'spidy/version'
require 'active_support/all'
require 'mechanize'
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
  autoload :Connector

  def self.console(filepath = nil)
    require 'pry'
    if filepath
      Pry.start(Spidy::Console.new(Spidy::DefinitionFile.open(filepath)))
    else
      Pry.start(Spidy::Console.new)
    end
  end

  def self.open(filepath)
    Spidy::DefinitionFile.open(filepath).spidy
  end

  def self.shell(filepath)
    Spidy::Shell.new(Spidy::DefinitionFile.open(filepath))
  end

  def self.define(&block)
    Module.new do
      class_eval do
        extend ::Spidy::Definition
        module_eval(&block)
      end
    end
  end
end
