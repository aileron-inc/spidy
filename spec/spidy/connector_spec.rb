require 'spec_helper'
require 'capybara_discoball'
require 'sinatra'

class ConnectorMock < Sinatra::Base
  get '/test.html' do
    <<-HTML
      <html>
        <head>
          <title>TEST</title>
        </head>
        <body>
          test
        </body>
      </html>
    HTML
  end

  get '/test.json' do
    content_type :json
    {
      title: 'test'
    }.to_json
  end

  get '/test.xml' do
    <<-XML
      <TEST>
        <A>TEST</A>
      </TEST>
    XML
  end
end

Capybara::Discoball.spin(ConnectorMock) do |server|
  ConnectorMock::BASE_URL = server.url
end

RSpec.describe Spidy::Connector do
  specify do
    expect(described_class.get(:html).origin_connector).to be_a(Spidy::Connector::Html)
  end

  specify do
    expect(described_class.get(:xml).origin_connector).to be_a(Spidy::Connector::Xml)
  end

  specify do
    expect(described_class.get(:json).origin_connector).to be_a(Spidy::Connector::Json)
  end

  specify do
    expect(described_class.get(:direct)).to be_a(Spidy::Connector::Direct)
  end

  describe 'static accessor' do
    specify :html do
      expect do
        Spidy::Connector::Html.call("#{ConnectorMock::BASE_URL}/test.html")
      end.not_to raise_error
    end

    specify :json do
      expect do
        Spidy::Connector::Json.call("#{ConnectorMock::BASE_URL}/test.json")
      end.not_to raise_error
    end

    specify :xml do
      expect do
        Spidy::Connector::Xml.call("#{ConnectorMock::BASE_URL}/test.xml")
      end.not_to raise_error
    end
  end

  specify :html do
    expect do
      described_class.get(:html).call("#{ConnectorMock::BASE_URL}/test.html")
    end.not_to raise_error
  end

  specify :json do
    expect do
      described_class.get(:json).call("#{ConnectorMock::BASE_URL}/test.json")
    end.not_to raise_error
  end

  specify :xml do
    expect do
      described_class.get(:xml).call("#{ConnectorMock::BASE_URL}/test.xml")
    end.not_to raise_error
  end

  specify :direct do
    expect(described_class.get(:direct).call('test')).to eq('test')
    expect(described_class.get(:direct).call('test') { |x| break x }).to eq('test')
  end
end
