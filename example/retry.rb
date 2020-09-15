Spidy.define do
  spider(as: :json) do |yielder, connector|
    connector.call('https://httpbin.org/status/500') do |json|
      yielder.call(json[:origin])
    end
  end
end
