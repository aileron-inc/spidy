#!/usr/bin/env ruby

# Simple Ferrum usage test

begin
  require 'ferrum'
  puts 'Successfully loaded Ferrum'
rescue LoadError => e
  puts "Ferrum is not installed: #{e.message}"
  puts "Run 'gem install ferrum' to install it"
  exit 1
end

puts 'Simple Browser Test'
puts '==================='

begin
  # Initialize Ferrum browser (headless mode)
  browser = Ferrum::Browser.new(headless: true)

  # Access URL
  url = 'https://react-shopping-cart-67954.firebaseapp.com/'
  puts "Accessing: #{url}"
  browser.goto(url)

  # Wait for page to load
  sleep 2

  # Get page title
  title = browser.title
  puts "Page title: #{title}"

  # Search for "Add to cart" buttons
  cart_buttons = browser.css('button.sc-124al1g-0')

  if cart_buttons.any?
    puts "\nFound #{cart_buttons.size} 'Add to cart' buttons"
  else
    puts "\nNo 'Add to cart' buttons found."

    # Try to get all buttons for debugging
    all_buttons = browser.css('button')
    puts "Found #{all_buttons.size} buttons on the page."
  end

  # Clean up browser
  browser.quit
rescue StandardError => e
  puts "Error: #{e.message}"
  puts e.backtrace.join("\n")
end

puts "\nTest completed"
