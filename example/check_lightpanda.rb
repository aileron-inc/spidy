#!/usr/bin/env ruby

# Script to check if Lightpanda is running and start it if needed
require 'net/http'

def lightpanda_running?(host = '127.0.0.1', port = 9222)
  uri = URI("http://#{host}:#{port}/json/version")
  response = Net::HTTP.get_response(uri)
  response.is_a?(Net::HTTPSuccess)
rescue StandardError
  false
end

def start_lightpanda(host = '127.0.0.1', port = 9222)
  puts 'Starting Lightpanda...'

  # Build the command to start Lightpanda in the background
  cmd = "/Users/aileron/bin/lightpanda serve --host #{host} --port #{port} > /tmp/lightpanda.log 2>&1 &"

  # Execute the command
  result = system(cmd)

  if result
    puts "Lightpanda started! Service should be available at http://#{host}:#{port}"

    # Wait for it to be ready
    10.times do
      if lightpanda_running?(host, port)
        puts 'Lightpanda is now running and accepting connections!'
        return true
      end
      puts 'Waiting for Lightpanda to start...'
      sleep 1
    end

    puts "Lightpanda might have started but isn't responding yet."
    puts 'Check /tmp/lightpanda.log for details.'
  else
    puts 'Failed to start Lightpanda. Make sure the path is correct: /Users/aileron/bin/lightpanda'
  end
  false
end

# Main script
host = '127.0.0.1'
port = 9222

if lightpanda_running?(host, port)
  puts "✅ Lightpanda is already running at http://#{host}:#{port}"
else
  puts "❌ Lightpanda is not running at http://#{host}:#{port}"

  if ARGV.include?('--start') || ARGV.include?('-s')
    start_lightpanda(host, port)
  else
    puts 'Run this script with --start or -s option to start Lightpanda automatically:'
    puts "  #{$PROGRAM_NAME} --start"
  end
end
