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
  autoload :Connector

  def self.console
    require 'pry'
    Pry.start(Spidy::Console.new)
  end

  def self.open(filepath)
    ::Spidy::DefinitionFile.open(filepath)
  end

  def self.define(&block)
    Class.new(::Spidy::Definition, &block)
  end
end
