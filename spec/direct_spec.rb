# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Spidy' do
  spidy = Spidy.define do
    define(as: :html, connector: :direct) do
      let(:title, '#title')
      let(:body, '#body')
    end
  end

  let(:html) do
    Nokogiri::HTML::Builder.new { |doc|
      doc.html {
        doc.body {
          doc.span.bold {
            doc.text "Hello world"
          }
          doc.h1("test_title", id: 'title')
          doc.main("test_body", id: 'body')
        }
      }
    }.doc
  end

  specify 'Objectized resources' do
    spidy.call(html) do |page|
      expect(page.title).to be_present
      expect(page.body).to be_present
    end
  end
end
