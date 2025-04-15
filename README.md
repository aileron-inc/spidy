# Spidy

![logo](https://github.com/aileron-inc/spidy/raw/master/spidy.png)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'spidy'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install spidy

## Usage

### Connectors

Spidy supports different connectors for fetching web pages:

1. **HTML Connector (Mechanize)**: Default connector for regular HTTP requests and HTML parsing
2. **JSON Connector**: For parsing JSON APIs
3. **XML Connector**: For parsing XML responses
4. **Lightpanda Connector**: For JavaScript-rendered websites (uses Playwright)

#### Lightpanda Connector for JavaScript-Rendered Websites

The Lightpanda connector allows you to process JavaScript-rendered websites by connecting to a running lightpanda CDP server.

##### Prerequisites

1. Install the Playwright Ruby client:

```bash
$ gem install playwright-ruby-client
```

2. Start a lightpanda CDP server in a separate terminal:

```bash
$ lightpanda serve --host 127.0.0.1 --port 9222
```

##### Usage

```ruby
# Define a scraper with lightpanda support
scraper = Spidy.define do
  # Use the :lightpanda connector for JavaScript-rendered sites
  spider(as: :lightpanda) do |yielder, connector, url|
    connector.call(url) do |page|
      # Process the JavaScript-rendered page
      # page is a Nokogiri-like object
      yielder.call(page)
    end
  end

  define(as: :html) do
    let(:title, 'title')
    # Extract content from JS-rendered page...
  end
end
```

##### Configuration

You can customize the lightpanda CDP server connection using environment variables:

```bash
# Set custom host and port
$ LIGHTPANDA_HOST=192.168.1.100 LIGHTPANDA_PORT=9333 ruby your_script.rb
```

Check `example/playwright_example.rb` for a complete example.

### Command Line Usage

Create a definition file (e.g., website.rb):
```rb
Spidy.define do
  spider(as: :html) do |yielder, connector, url|
    connector.call(url) do |html|
      # html is a Nokogiri object (from Mechanize)
      yielder.call(url)
    end
  end

  define(as: :html) do
    let(:object_name, 'nokogiri query')
  end
end
```

Use it from the command line:
```bash
echo 'http://example.com' | spidy each website.rb > urls
cat urls | spidy call website.rb > website.json
# shorthand
echo 'http://example.com' | spidy each website.rb | spidy call website.rb | jq .
```

### Development Console

Start an interactive console with your definition:
```bash
spidy console website.rb
```

Reload your source code during development:
```
irb(#<Spidy::Console>)> reload!
```

Example console usage:
```rb
each('http://example.com') { |url| break url }
call('http://example.com') { |html| break html } # html is a Nokogiri object (from Mechanize)
```

### Ruby Code Usage

Create and use a scraper in your Ruby code:
```rb
scraper = Spidy.define do
  # Implement spiders and scrapers
  spider(as: :html) do |yielder, connector, url|
    connector.call(url) do |page|
      yielder.call(page)
    end
  end
  
  define(as: :html) do
    let(:title, 'title')
    let(:links) { |doc| doc.css('a').map { |a| a['href'] } }
  end
end

# Extract URLs from a site
scraper.each(url) do |page_url|
  # Process each URL found
  puts page_url
end

# Extract structured data from a site
result = scraper.call(url)
puts "Title: #{result[:title]}"
puts "Found #{result[:links].size} links"
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/aileron-inc/spidy. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Crawler project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/aileron-inc/spidy/blob/master/CODE_OF_CONDUCT.md).
