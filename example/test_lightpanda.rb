#!/usr/bin/env ruby

# This script tests the fixed Lightpanda connector

require_relative '../lib/spidy'

# Enable debug output
ENV['DEBUG'] = 'true'

# Define a scraper using the lightpanda connector
scraper = Spidy.define do
  # Define user agent
  user_agent 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) ' \
             'AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'

  # Define a spider that uses the lightpanda connector
  spider(as: :lightpanda) do |yielder, connector, url|
    puts "Processing page with Chrome/Lightpanda: #{url}"
    connector.call(url) do |page|
      yielder.call(page)
    end
  end

  # Define the object structure we want to extract
  define(as: :html) do
    let(:title, 'title')

    # Example: extract links
    let(:links) do |doc|
      doc.css('a').take(5).map do |link|
        {
          text: link.text.to_s.strip,
          href: link['href'].to_s
        }
      end
    end
  end
end

# URL to scrape
url = 'https://example.com'

puts '=== Testing Chrome/Lightpanda Connection ==='
puts "URL: #{url}\n\n"

begin
  # First, check if Lightpanda is running
  require 'net/http'
  version_url = URI('http://127.0.0.1:9222/json/version')
  http = Net::HTTP.new(version_url.host, version_url.port)
  response = http.get(version_url.path)

  if response.code == '200'
    puts 'Lightpanda is running at 127.0.0.1:9222'
    puts "Version info: #{response.body[0..100]}...\n\n"
  else
    puts "Warning: Couldn't connect to Lightpanda at 127.0.0.1:9222"
    puts "Make sure it's running with: /Users/aileron/bin/lightpanda serve --host 127.0.0.1 --port 9222\n\n"
  end
rescue StandardError => e
  puts "Error checking Lightpanda: #{e.message}"
  puts "Make sure Lightpanda is running with: /Users/aileron/bin/lightpanda serve --host 127.0.0.1 --port 9222\n\n"
end

begin
  # Execute the scraper
  result = scraper.call(url)

  # Display the results
  puts "Page Title: #{result.title}"

  if result.links&.any?
    puts "\nFound #{result.links.size} links:"

    result.links.each_with_index do |link, index|
      puts "  #{index + 1}. #{link[:text]} - URL: #{link[:href]}"
    end
  else
    puts "\nNo links found."
  end
rescue StandardError => e
  puts "Error: #{e.message}"
  puts e.backtrace.join("\n")
end

puts "\n=== Test completed ==="
