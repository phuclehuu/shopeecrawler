defmodule ShopeeSpider do
  def fetch(url) do
    response = Crawly.fetch(url)

    items = parse_item(response)

    items
  end

  defp parse_item(response) do
    {:ok, document} = Floki.parse_document(response.body)

    {:ok, results} = Poison.decode(document)

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
end
