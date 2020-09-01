Spidy.define do
  user_agent 'Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:59.0) Gecko/20100101 Firefox/59.0'
  socks_proxy '127.0.0.1', 9050 if tor?

  spider(as: :json) do |yielder, connector|
    connector.call('https://httpbin.org/ip') do |json|
      yielder.call(json[:origin])
    end
  end
end
