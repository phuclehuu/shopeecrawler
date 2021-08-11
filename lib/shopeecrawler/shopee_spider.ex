defmodule ShopeeSpider do
  def fetch(url, params \\ %{}) do
    response = Crawly.fetch(url)

    items = parse_item(response)

    case search_term = get_in(params, ["query"]) do
      nil ->
        items
      _ ->
        Enum.filter(items, fn item ->
          {:ok, search_reg} = Regex.compile(Regex.escape(search_term), "i")
          String.match?(item["name"], search_reg) == true
        end)
    end
  end

  def fetch_cats(url) do
    response = Crawly.fetch(url)

    cats = parse_cat(response)

    cats
  end

  defp parse_item(response) do
    {:ok, results} = parse_response(response)

    case results["error"] do
      nil ->
        Enum.map(results["items"], fn item ->
          item_info = item["item_basic"]

          name = item_info["name"]

          image = item_info["image"]

          price = String.slice(Integer.to_string(item_info["price"]), 0..-6)

          sold = item_info["sold"]

          %{
            "name" => name,
            "image" => image,
            "price" => price,
            "sold" => sold
          }
        end)

      _ -> []
    end
  end

  defp parse_cat(response) do
    {:ok, results} = parse_response(response)

    case results["error"] do
      e when e in [nil, 0] ->
        Enum.map(results["data"]["shop_categories"], fn cat ->
          category_id = cat["shop_category_id"]

          name = cat["display_name"]

          image = cat["image"]

          %{
            "name" => name,
            "image" => image,
            "category_id" => category_id,
            "slug" => "/category/#{category_id}"
          }
        end)

      _ ->
        []
    end
  end

  defp parse_response(response) do
    case Floki.parse_document(response.body) do
      {:ok, document} ->
        Poison.decode(document)
      _ ->
        {:ok, %{:error => "Can't parse response"}}
    end
  end
end
