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
end
