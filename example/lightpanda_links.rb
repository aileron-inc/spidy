#!/usr/bin/env ruby
# Enhanced Lightpanda link extractor

Spidy.define do
  # Set wait time to avoid timeouts
  wait_time 10

  # Set a standard user agent
  user_agent 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) ' \
             'AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'

  spider(as: :lightpanda) do |yielder, connector, start_url|
    puts "Extracting links from: #{start_url}" if ENV['DEBUG']

    connector.call(start_url) do |page|
      links = page.search('a')
      puts "Found #{links.size} links on page" if ENV['DEBUG']

      links.each do |a|
        # Try different ways to get the href attribute
        href = nil

        # First try the hash access method
        begin
          href = a['href']
        rescue StandardError
          # Then try the attr method
          begin
            href = a.attr('href')
          rescue StandardError
            # Then try the attribute method
            begin
              href = a.attribute('href')&.to_s
            rescue StandardError
              # Give up on this link
              next
            end
          end
        end

        # Skip empty or invalid links
        next if href.nil? || href.empty? || href == '#'

        # Try to get link text for better output
        link_text = nil

        # Try different ways to get the text
        begin
          link_text = a.text.to_s.strip
        rescue StandardError
          begin
            link_text = a.inner_text.to_s.strip
          rescue StandardError
            begin
              link_text = a.content.to_s.strip
            rescue StandardError
              link_text = '(Could not extract text)'
            end
          end
        end

        # Truncate long text
        link_text = "#{link_text[0...47]}..." if link_text.length > 50
        link_text = '(No text)' if link_text.nil? || link_text.empty?

        # Output the link with its text if in debug mode
        puts "  - #{link_text}: #{href}" if ENV['DEBUG']

        # Yield the link
        yielder.call(href)
      end
    rescue StandardError => e
      puts "Error processing links: #{e.message}" if ENV['DEBUG']
      raise e
    end
  rescue StandardError => e
    puts "Error in spider: #{e.message}" if ENV['DEBUG']
    raise e
  end
end
