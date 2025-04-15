require 'spec_helper'

RSpec.describe 'Spidy' do
  spidy = Spidy.define do
    define(as: :html, connector: :direct) do
      let(:title, '#title')
      let(:body, '#body')
    end
  end

  let(:html) do
    Nokogiri::HTML::Builder.new do |doc|
      doc.html do
        doc.body do
          doc.span.bold do
            doc.text 'Hello world'
          end
          doc.h1('test_title', id: 'title')
          doc.main('test_body', id: 'body')
        end
      end
    end.doc
  end

  specify 'Objectized resources' do
    spidy.call(html) do |page|
      expect(page.title).to be_present
      expect(page.body).to be_present
    end
  end
end
