# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Spidy::Connector do
  specify do
    expect(Spidy::Connector.get(:html).origin_connector).to be_kind_of(Spidy::Connector::Html)
  end
  specify do
    expect(Spidy::Connector.get(:xml).origin_connector).to be_kind_of(Spidy::Connector::Xml)
  end
  specify do
    expect(Spidy::Connector.get(:json).origin_connector).to be_kind_of(Spidy::Connector::Json)
  end
  specify do
    expect(Spidy::Connector.get(:direct).origin_connector).to be_kind_of(Spidy::Connector::Direct)
  end
end
