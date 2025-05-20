#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../lib/spidy'

# Define a scraper that uses the Lightpanda connector for Instagram profile
scraper = Spidy.define do
  # Set a user agent to mimic a desktop browser
  user_agent 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) ' \
             'AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'

  # Define a spider that uses the Lightpanda connector
  spider(as: :lightpanda) do |yielder, connector, url|
    puts "Processing Instagram profile: #{url}" if ENV['DEBUG']
    connector.call(url) do |page|
      yielder.call(page)
    end
  end

  # Define the object structure we want to extract
  define(as: :lightpanda) do
    let(:title) { html.title }
    
    let(:profile_name) { html.at('meta[property="og:title"]')&.[]('content') }
    
    let(:description) { html.at('meta[property="og:description"]')&.[]('content') }
    
    let(:image) { html.at('meta[property="og:image"]')&.[]('content') }
    
    let(:followers_count) do
      # Try to extract followers count from various possible locations
      text = html.css('span._ac2a, span._aacl, span[data-count]').detect do |el|
        el.text =~ /followers/i
      end&.text
      
      if text
        # Extract just the number
        text.gsub(/[^\d,\.]/, '').gsub(/[,\.]/, '').to_i
      else
        nil
      end
    end
    
    let(:posts) do
      html.css('article img').map do |img|
        {
          src: img['src'],
          alt: img['alt']
        }
      end
    end
  end
end

# Get the URL from stdin
url = STDIN.read.strip

begin
  # Run the scraper
  result = scraper.call(url)
  
  # Output the results
  puts "---- Instagram Profile: #{result.profile_name} ----"
  puts "Description: #{result.description}"
  puts "Followers: #{result.followers_count || 'Unable to extract'}"
  puts "\nProfile Image: #{result.image}" if result.image
  
  puts "\nRecent Posts: #{result.posts.size}"
  result.posts.each_with_index do |post, i|
    puts "#{i+1}. #{post[:alt] || 'No description'}"
    puts "   #{post[:src]}"
  end
rescue StandardError => e
  puts "Error processing profile: #{e.message}"
  puts e.backtrace if ENV['DEBUG']
  exit 1
end