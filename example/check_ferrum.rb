#!/usr/bin/env ruby

# This script checks what Ferrum API methods are available
begin
  require 'ferrum'
  puts 'Ferrum gem is loaded!'

  # Check Ferrum version
  puts "Ferrum version: #{begin
    Ferrum::VERSION
  rescue StandardError
    'unknown'
  end}"

  # Try to create a browser instance
  puts "\nTrying to create a browser instance..."

  # Find Chrome executable path
  def find_chrome_path
    # Common locations on macOS
    macos_paths = [
      '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome',
      '/Applications/Google Chrome Canary.app/Contents/MacOS/Google Chrome Canary',
      '/Applications/Chromium.app/Contents/MacOS/Chromium',
      '/Applications/Microsoft Edge.app/Contents/MacOS/Microsoft Edge'
    ]

    # Check macOS paths
    macos_paths.each do |path|
      return path if File.exist?(path)
    end

    # Try to locate Chrome using 'which' command
    %w[google-chrome chromium chromium-browser].each do |browser|
      path = `which #{browser} 2>/dev/null`.strip
      return path if path != '' && File.exist?(path)
    end

    nil
  end

  # Get Chrome path
  chrome_path = ENV['CHROME_PATH'] || find_chrome_path
  if chrome_path
    puts "Using Chrome executable: #{chrome_path}"
  else
    puts 'No Chrome executable found. Using default.'
  end

  # Create browser with options
  options = {
    headless: true,
    window_size: [1280, 800]
  }

  # Add Chrome path if available
  options[:browser_path] = chrome_path if chrome_path

  browser = Ferrum::Browser.new(options)
  puts 'Browser instance created successfully!'

  # Check available methods on browser
  puts "\nAvailable methods on browser object:"
  browser_methods = (browser.methods - Object.methods).sort
  puts browser_methods.join(', ')

  # Check if headers method exists
  puts "\nDoes browser respond to 'headers='? #{browser.respond_to?(:headers=)}"

  # Check available methods on browser.network
  if browser.respond_to?(:network)
    puts "\nAvailable methods on browser.network object:"
    network_methods = (browser.network.methods - Object.methods).sort
    puts network_methods.join(', ')

    # Check if wait_for_idle method exists and what parameters it accepts
    if browser.network.respond_to?(:wait_for_idle)
      puts "\nExamine wait_for_idle method:"
      begin
        # Try with timeout parameter
        browser.network.wait_for_idle(timeout: 1)
        puts 'wait_for_idle accepts timeout parameter'
      rescue ArgumentError => e
        puts "wait_for_idle does not accept timeout parameter: #{e.message}"
      rescue StandardError => e
        puts "Error calling wait_for_idle with timeout: #{e.message}"
      end
    else
      puts "\nwait_for_idle method not available on network object"
    end
  else
    puts "\nnetwork method not available on browser object"
  end

  # Test goto method
  puts "\nTesting navigation with goto method:"
  begin
    browser.goto('https://example.com')
    puts 'Navigation successful!'
    puts "Page title: #{browser.title}"
  rescue StandardError => e
    puts "Error during navigation: #{e.message}"
  end

  # Clean up
  browser.quit
  puts "\nBrowser closed successfully"
rescue LoadError => e
  puts "Error: Ferrum gem is not installed: #{e.message}"
  puts 'Install it with: gem install ferrum'
rescue StandardError => e
  puts "Error: #{e.message}"
  puts e.backtrace.join("\n")
end
