defmodule ShopeecrawlerWeb.PageController do
  use ShopeecrawlerWeb, :controller
  @url "https://shopee.vn/api/v4/search/search_items?by=pop&limit=30&match_id=88201679&newest=0&order=desc&page_type=shop&scenario=PAGE_OTHERS&version=2"
  @state %{table: :simple_cache}

  def index(conn, _params) do
    items = SimpleCache.get(@state, ShopeeSpider, :fetch, [@url], ttl: 10)

    render(conn, "index.html", data: items)
  end
end
