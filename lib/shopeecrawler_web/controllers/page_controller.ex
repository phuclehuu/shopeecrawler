defmodule ShopeecrawlerWeb.PageController do
  use ShopeecrawlerWeb, :controller

  @url "https://shopee.vn/api/v4/search/search_items?by=pop&limit=30&match_id=88201679&newest=0&order=desc&page_type=shop&scenario=PAGE_OTHERS&version=2"
  @url_category "https://shopee.vn/api/v4/shop/get_categories?limit=20&offset=0&shopid=88201679"

  def index(conn, params) do
    # shop_categoryids = get_in(params, ["shop_categoryids"])

    # items =
    #   SimpleCache.get(
    #     ShopeeSpider,
    #     :fetch,
    #     ["#{@url}&shop_categoryids=#{shop_categoryids}", params],
    #     ttl: 60
    #   )

    # categories = SimpleCache.get(ShopeeSpider, :fetch_cats, [@url_category], ttl: 120)

    {:ok, %{"data" => %{"divisions" => regions}}} =
      ShopeeSpider.fetch_locations(
        "https://test-stable.shopee.ph/api/v4/location/get_child_division_list?division_id=0"
      )

    regions =
      regions
      |> Enum.map(&Map.put(&1, "parent_id", "0"))
      |> IO.inspect(label: "Regions: ")

    export(regions, "regions.csv")

    result_provinces =
      Enum.reduce(regions, [], fn div, acc ->
        url =
          "https://test-stable.shopee.ph/api/v4/location/get_child_division_list?division_id=#{div["id"]}"

        {:ok, %{"data" => %{"divisions" => provinces}}} = ShopeeSpider.fetch_locations(url)
        Enum.map(provinces, &Map.put(&1, "parent_id", div["id"])) ++ acc
      end)
      |> IO.inspect(label: "Provinces: ")

    export(result_provinces, "provinces.csv")

    result_cities =
      Enum.reduce(result_provinces, [], fn div, acc ->
        url =
          "https://test-stable.shopee.ph/api/v4/location/get_child_division_list?division_id=#{div["id"]}"

        {:ok, %{"data" => %{"divisions" => cities}}} = ShopeeSpider.fetch_locations(url)
        Enum.map(cities, &Map.put(&1, "parent_id", div["id"])) ++ acc
      end)
      |> IO.inspect(label: "Cities: ")

    export(result_cities, "cities.csv")

    result_barangays =
      Enum.reduce(result_cities, [], fn div, acc ->
        url =
          "https://test-stable.shopee.ph/api/v4/location/get_child_division_list?division_id=#{div["id"]}"

        {:ok, %{"data" => %{"divisions" => barangays}}} = ShopeeSpider.fetch_locations(url)
        Enum.map(barangays, &Map.put(&1, "parent_id", div["id"])) ++ acc
      end)
      |> IO.inspect(label: "Barangays: ")

    export(result_barangays, "barnagays.csv")

    render(conn, "index.html", data: %{categories: [], items: [], active: "home"})
  end

  defp export(data, file_name) do
    {:ok, file} = File.open(file_name, [:write, :utf8])

    content =
      Enum.reduce(data, "", fn r, acc ->
        "#{r["division_name"]},#{r["parent_id"]}\n#{acc}"
      end)

    IO.write(file, content)

    File.close(file)
  end

  def category(conn, %{"id" => shop_categoryids}) do
    items =
      SimpleCache.get(ShopeeSpider, :fetch, ["#{@url}&shop_categoryids=#{shop_categoryids}", %{}],
        ttl: 60
      )

    categories = SimpleCache.get(ShopeeSpider, :fetch_cats, [@url_category], ttl: 120)

    render(conn, "index.html",
      data: %{categories: categories, items: items, active: shop_categoryids}
    )
  end
end
