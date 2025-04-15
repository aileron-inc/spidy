Spidy.define do
  url_to_params = lambda { |url|
    uri = URI.parse(url)
    params = URI.decode_www_form(uri.query).to_h if uri.query.present?
    params if params.present?
  }

  master_page = proc { |url, &yielder|
    params = url_to_params.call(url)
    page = params&.dig('page').to_i

    limit_page = 3
    per_page = 25
    yielder.call(Nokogiri::HTML::Builder.new do |doc|
      doc.html do
        doc.body do
          doc.span.bold do
            doc.text 'Hello world'
          end
          doc.main do
            ((page * per_page) + 1).upto((page + 1) * per_page).each do |i|
              doc.a("page #{i}", href: "http://localhost/?id=#{i}")
            end
          end
          doc.a('NEXT', href: "http://localhost/?page=#{page + 1}", class: 'next') if page < limit_page
        end
      end
    end.doc)
  }

  detail_page = proc { |url, &yielder|
    params = url_to_params.call(url)
    id = params['id']

    yielder.call(Nokogiri::HTML::Builder.new do |doc|
      doc.html do
        doc.body do
          doc.span.bold do
            doc.text 'Hello world'
          end
          doc.h1("title_#{id}", id: 'title')
          doc.main("body_#{id}", id: 'body')
          doc.div.sub do
            doc.span.name('testtest')
          end
        end
      end
    end.doc)
  }

  define(as: :html, connector: detail_page) do
    let(:title, '#title')
    let(:body, '#body')
  end

  define(:sub, as: :html, connector: :direct) do
    let(:name, '.name')
  end

  spider(as: :html, connector: master_page) do |yielder, connector|
    next_url = 'http://localhost'
    while next_url.present?
      connector.call(next_url) do |page|
        page.search('main a').each do |a|
          yielder.call(a.attr('href'))
        end
        next_url = page.at('a.next')&.attr('href')
      end
    end
  end
end
