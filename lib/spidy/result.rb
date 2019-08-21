# frozen_string_literal: true

#
# Scrape results
#
class Spidy::Result
  include ActiveModel::Model
  include ActiveModel::Attributes

  def self.define(name, presence: true)
    case name
    when /.*\?/
      attribute name, :boolean
      validates name, inclusion: { in: [true, false] } if presence
    else
      attribute name
      validates name, presence: true, allow_blank: true if presence
    end
  end

  attribute :fetched_at
  attribute :fetched_on
end
