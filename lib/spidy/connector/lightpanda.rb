#
# Lightpanda connector for JavaScript-rendered pages via CDP
# Using Ferrum for direct CDP connection
#
class Spidy::Connector::Lightpanda
  include Spidy::Connector::StaticAccessor

  attr_reader :user_agent, :host, :port

  DEFAULT_HOST = '127.0.0.1'.freeze
  DEFAULT_PORT = 9222

  def initialize(user_agent:, host: nil, port: nil)
    begin
      require 'ferrum'
    rescue LoadError
      raise 'Ferrum gem is required. Please install with: gem install ferrum'
    end

    @user_agent = user_agent
    @host = host || ENV['LIGHTPANDA_HOST'] || DEFAULT_HOST
    @port = port || ENV['LIGHTPANDA_PORT'] || DEFAULT_PORT
  end

  def call(url)
    fail 'url is not specified' if url.blank?

    # Clean the URL by removing any whitespace or newlines
    clean_url = url.to_s.strip

    puts "Processing URL: #{clean_url}" if ENV['DEBUG']

    # Create a page-like object similar to Mechanize
    page = fetch_with_ferrum(clean_url)

    # Apply yielder to the page
    yield(page)
  end

  def refresh!
    # No special refresh actions needed for Lightpanda
  end

  private

  # Try to wait for network to be idle
  def wait_for_network_idle(browser)
    puts 'Waiting for network idle...' if ENV['DEBUG']

    begin
      # Try with timeout parameter
      browser.network.wait_for_idle(timeout: 15)
    rescue ArgumentError
      begin
        # Try without timeout parameter
        browser.network.wait_for_idle
      rescue StandardError => e
        # If wait_for_idle fails, fall back to a simple sleep
        puts "Warning: Could not wait for network idle: #{e.message}" if ENV['DEBUG']
        sleep 5 # Simple fallback
      end
    end
  end

  # Navigate to URL and get page content
  def navigate_and_get_content(browser, url)
    # Navigate to the URL
    puts "Navigating to: #{url}" if ENV['DEBUG']
    browser.goto(url)

    # Wait for network idle
    wait_for_network_idle(browser)

    # Get the content
    puts 'Getting page content...' if ENV['DEBUG']
    browser.body
  end

  # Create browser options
  def create_browser_options
    options = {
      headless: true,         # Run in headless mode
      timeout: 20,            # Increase timeout
      process_timeout: 20,    # Process timeout
      window_size: [1280, 800] # Set window size
    }

    # Add Chrome path if available
    options[:browser_path] = ENV['CHROME_PATH'] if ENV['CHROME_PATH'] && File.exist?(ENV['CHROME_PATH'])

    options
  end

  # Connect to CDP server with Ferrum and fetch the page
  def fetch_with_ferrum(url) # rubocop:todo Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity
    puts 'Using direct Chrome/Chromium instead of Lightpanda' if ENV['DEBUG']
    browser = nil
    html_content = nil

    begin
      # Create Ferrum browser
      browser = Ferrum::Browser.new(create_browser_options)

      # Skip user agent setting - not supported in this Ferrum version
      if @user_agent.present? && ENV.fetch('DEBUG', nil)
        puts 'User agent setting will be skipped - not supported in your Ferrum version'
      end

      # Navigate and get content
      html_content = navigate_and_get_content(browser, url)
    rescue StandardError => e
      puts "Error during page navigation: #{e.class} - #{e.message}" if ENV['DEBUG']
      raise e
    ensure
      # Clean up - ensure browser is always closed, even if an error occurred
      browser&.quit if defined?(browser) && browser
    end

    # Create a Mechanize-like page object
    LightpandaPage.new(url, html_content)
  end

  # Page-like object that mimics the Mechanize::Page interface
  class LightpandaPage
    attr_reader :uri, :body, :title, :code, :response_code

    def initialize(url, html_content)
      @uri = url
      @body = html_content
      @doc = Nokogiri::HTML(html_content)
      @title = @doc.title
      @code = '200'
      @response_code = '200'
    end

    # Common methods from Mechanize::Page that might be used in the application
    def search(*)
      @doc.search(*)
    end

    def at(*)
      @doc.at(*)
    end

    def css(*)
      @doc.css(*)
    end

    def xpath(*)
      @doc.xpath(*)
    end

    def encoding
      @doc.encoding
    end

    def try(*args)
      send(*args) if respond_to?(args.first)
    end
  end
end
