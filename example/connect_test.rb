#!/usr/bin/env ruby

# Test connecting to existing Chrome instance at 127.0.0.1:9222

begin
  require 'ferrum'
  puts 'Successfully loaded Ferrum'
rescue LoadError => e
  puts "Ferrum is not installed: #{e.message}"
  puts "Run 'gem install ferrum' to install it"
  exit 1
end

puts 'Testing connection to Chrome at 127.0.0.1:9222'
puts '=============================================='

begin
  # Connect to the remote Chrome instance
  # Note: We're setting process: false to prevent launching a new browser
  browser = Ferrum::Browser.new(
    url: 'http://127.0.0.1:9222',
    process: false
  )

  # Access a test URL
  url = 'https://example.com'
  puts "Accessing: #{url}"
  browser.goto(url)

  # Get page title
  title = browser.title
  puts "Page title: #{title}"

  # Clean up browser connection (but don't close Chrome)
  browser.quit

  puts "\nSuccess! Connected to Chrome at 127.0.0.1:9222"
rescue StandardError => e
  puts "Error: #{e.message}"
  puts e.backtrace.join("\n")

  puts "\nTroubleshooting tips:"
  puts '1. Make sure Chrome is running with remote debugging enabled'
  puts '2. Verify the command: /Users/aileron/bin/lightpanda serve --host 127.0.0.1 --port 9222'
  puts '3. Check if you can access http://127.0.0.1:9222/json/version in your browser'
end

puts "\nTest completed"
