# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Master detail page' do
  spidy = Spidy.open("#{__dir__}/../example/master_detail.rb")

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

      spidy.call(page.html, name: :sub) do |sub_page|
        expect(sub_page.name).to eq('testtest')
      end
    end
  end
end
