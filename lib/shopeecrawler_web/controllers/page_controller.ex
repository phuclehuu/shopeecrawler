defmodule ShopeecrawlerWeb.PageController do
  use ShopeecrawlerWeb, :controller
  @url "https://shopee.vn/api/v4/search/search_items?by=pop&limit=30&match_id=88201679&newest=0&order=desc&page_type=shop&scenario=PAGE_OTHERS&version=2"
  @url_category "https://shopee.vn/api/v4/shop/get_categories?limit=20&offset=0&shopid=88201679"

  def index(conn, params) do
    shop_categoryids = get_in(params, ["shop_categoryids"])

    items = SimpleCache.get(ShopeeSpider, :fetch, ["#{@url}&shop_categoryids=#{shop_categoryids}", params], ttl: 60)

    categories = SimpleCache.get(ShopeeSpider, :fetch_cats, [@url_category], ttl: 120)

    render(conn, "index.html", data: %{categories: categories, items: items, active: "home"})
  end

  def category(conn, %{"id" => shop_categoryids}) do
    items = SimpleCache.get(ShopeeSpider, :fetch, ["#{@url}&shop_categoryids=#{shop_categoryids}", %{}], ttl: 60)

    categories = SimpleCache.get(ShopeeSpider, :fetch_cats, [@url_category], ttl: 120)

    render(conn, "index.html", data: %{categories: categories, items: items, active: shop_categoryids})
  end
end
