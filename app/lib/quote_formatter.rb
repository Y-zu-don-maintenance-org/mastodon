class QuoteFormatter
  include ActionView::Helpers::TextHelper
  include ERB::Util
  include RoutingHelper

  def initialize(html, quote, options = {})
    @html    = html
    @quote   = quote
    @options = options
  end

  def to_s
    return html if status.quote? && !options[:escape_quotify]
    
    url = ActivityPub::TagManager.instance.url_for(status.quote)
    link = encode_and_link_urls(url)
    html.sub(/(<[^>]+>)\z/, "<span class=\"quote-inline\"><br/>QT: #{link}</span>\\1")
  end

  def format_in_quote(status, **options)
    # format_in_quoteを定義、引数statusと**options
    html = format(status)
    return '' if html.empty?
    doc = Nokogiri::HTML.parse(html, nil, 'utf-8')
    html = doc.css('body')[0].inner_html
    html.sub!(/^<p>(.+)<\/p>$/, '\1')
    html = Sanitize.clean(html).delete("\n").truncate(150)
    html = encode_custom_emojis(html, status.emojis) if options[:custom_emojify]
    html.html_safe
  end
  
end
