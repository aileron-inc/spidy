#!/usr/bin/env ruby

# This is a wrapper script that ensures Lightpanda is running before executing Spidy commands

require_relative 'check_lightpanda'

# Check if Lightpanda is running, start it if not
unless lightpanda_running?
  puts 'Lightpanda is not running. Starting it now...'
  unless start_lightpanda
    puts 'Failed to start Lightpanda. Exiting.'
    exit 1
  end
end

# Execute the Spidy command with debug mode enabled
ENV['DEBUG'] = 'true'
url = ARGV[0] || 'https://example.com'
definition = ARGV[1] || 'example/lightpanda_links.rb'

puts "Running Spidy with URL: #{url} and definition: #{definition}"
cmd = "echo '#{url}' | spidy each #{definition}"

puts "Executing: #{cmd}"
exec(cmd)
