# frozen_string_literal: true

#
# Bind resource received from the connection to the result object
#
module Spidy::Binder
  extend ActiveSupport::Autoload
  autoload :Json
  autoload :Html
  autoload :Xml
end
