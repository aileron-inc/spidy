#
# Bind resource received from the connection to the result object
#
module Spidy::Binder
  extend ActiveSupport::Autoload
  autoload :Error
  autoload :Json
  autoload :Html
  autoload :Xml
end
