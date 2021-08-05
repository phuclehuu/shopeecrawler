defmodule ShopeeSpiderTest do
  use ExUnit.Case
  doctest ShopeeSpider

  test "fetch/2 crawling products" do
    assert ShopeeSpider.fetch("https://shopee.vn/api/v4/search/search_items?by=pop&limit=30&match_id=88201679&newest=0&order=desc&page_type=shop&scenario=PAGE_OTHERS&version=2") |> is_list()
    assert ShopeeSpider.fetch("https://shopee.vn/api/v4/search/search_items?by=pop&limit=30&match_id=88201679&newest=0&order=desc&page_type=shop&scenario=PAGE_OTHERS&version=2", %{query: :apple}) |> is_list()
  end
end
