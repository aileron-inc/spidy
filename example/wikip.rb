Spidy.define do
  def self.infobox_scrape(params, &)
    call(params.html.at('.infobox'), name: :infobox, &)
  end

  define(as: :html) do
    let(:title, 'h1')
  end

  define(:infobox, as: :html, connector: :direct) do
    let(:columns) do
      html.search('tr').map do |tr|
        { name: tr.at('th')&.text, value: tr.at('td')&.text }
      end
    end
  end
end
