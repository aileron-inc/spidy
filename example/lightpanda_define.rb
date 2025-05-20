require 'spidy'

# Define a scraper using LightPanda (JavaScript-rendered pages)
definition = Spidy::Shell.run do
  user_agent 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.82 Safari/537.36'

  # Define a scraper using LightPanda
  define(as: :lightpanda) do
    let(:title) { html.title }
    let(:headings) { html.css('h1, h2, h3').map { it.text.strip } }
    let(:links) { html.css('a').map { |a| { href: a['href'], text: a.text.strip } } }
  end
end

# Execute the scraper on a JavaScript-heavy website
result = definition.call('https://www.example.com')

puts "Title: #{result.title}"
puts "\nHeadings:"
result.headings.each do |heading|
  puts "- #{heading}"
end

puts "\nLinks:"
result.links.each do |link|
  puts "- #{link[:text]} (#{link[:href]})"
end

