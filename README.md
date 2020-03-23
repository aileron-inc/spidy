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

### When used from the command line

website.rb
```rb
Spidy.defin do
  spider(as: :html) do |yielder, connector, url|
    connector.call(url) do |html|
      # html as nokogiri object ( mechanize )
      yielder.call(url)
    end
  end

  define(as: :html) do
    let(:object_name, 'nokogiri query')
  end
end
```
```bash
echo 'http://example.com' | spidy each website.rb > urls
cat urls | spidy call website.rb > website.json
# shorthands
echo 'http://example.com' | spidy each website.rb | spidy call website.rb | jq .
```

### When development console
```bash
spidy console website.rb
```

### reload source code
```
pry(#<Spidy::Console>)> reload!
```

```rb
each('http://example.com') { |url| break url }
call('http://example.com') { |html| break html } # html as nokogiri object ( mechanize )
```

### When used from the ruby code
```rb
a = Spidy.define do
  # Implementing spiders and scrapers
end

a.each(url) do |url|
  # Loop for the number of retrieved URLs
end

a.call(url) do |object|
  # The scrape result is passed as a defined object
end
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
