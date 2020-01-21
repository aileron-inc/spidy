# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Master detail page' do
  url_to_params = ->(url) {
    uri = URI.parse(url)
    params = URI.decode_www_form(uri.query).to_h if uri.query.present?
    params if params.present?
  }

  master_page = proc { |url, &yielder|
    params = url_to_params.call(url)
    page = params&.dig('page')&.to_i || 0

    limit_page = 3
    per_page = 25
    yielder.call(Nokogiri::HTML::Builder.new { |doc|
      doc.html {
        doc.body {
          doc.span.bold {
            doc.text "Hello world"
          }
          doc.main {
            (page * per_page + 1).upto((page + 1) * per_page).each do |i|
              doc.a("page #{i}", href: "http://localhost/?id=#{i}")
            end
          }
          doc.a('NEXT', href: "http://localhost/?page=#{page + 1}", class: 'next') if page < limit_page
        }
      }
    }.doc)
  }

  detail_page = proc { |url, &yielder|
    params = url_to_params.call(url)
    id = params['id']

    yielder.call(Nokogiri::HTML::Builder.new { |doc|
      doc.html {
        doc.body {
          doc.span.bold {
            doc.text "Hello world"
          }
          doc.h1("title_#{id}", id: 'title')
          doc.main("body_#{id}", id: 'body')
        }
      }
    }.doc)
  }

  spidy = Spidy.define do
    define(as: :html, connector: detail_page) do
      let(:title, '#title')
      let(:body, '#body')
    end
    spider(as: :html, connector: master_page) do |yielder, connector|
      next_url = 'http://localhost'
      while next_url.present?
        connector.call(next_url) do |page|
          page.search('main a').each do |a|
            yielder.call(a.attr('href'))
          end
          next_url = page.at('a.next')&.attr('href')
        end
      end
    end
  end

  specify 'each' do
    last_url = nil
    count = 0
    spidy.each do |url|
      last_url = last_url
      count += 1
    end
    expect(count).to eq(100)
  end

  specify 'call' do
    url = spidy.each { |url| break url }
    expect(url).to eq('http://localhost/?id=1')
    spidy.call(url) do |page|
      expect(page.title).to be_present
      expect(page.body).to be_present
    end
  end
end
