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

  def fetch_locations(url) do
    response =
      Crawly.fetch(url,
        headers: [
          cookie:
            "_gcl_au=1.1.290635081.1642585014; REC_T_ID=568204d1-790b-11ec-b288-9440c9436168; SPC_F=XbLvbw0h04iXplsO5CXsq9A6EGdjKNKF; csrftoken=KvVGPcB8P1S0f7w2E3FZmBpQyjvnVDhg; SPC_IA=-1; _QPWSDCXHZQA=d709e033-a1ec-4787-ddf2-8e00552bbfe0; _fbp=fb.1.1642585014973.551654441; G_ENABLED_IDPS=google; SPC_CLIENTID=WGJMdmJ3MGgwNGlYmkolkbezqwjjbcwy; SC_DFP=M2qCLO4gb2CV8hVfwK7e9WyoJGmsnIle; _gid=GA1.2.332923173.1646625108; SPC_SI=mall.Dx3lKJ4aC7KEJudK0ijYIsbpLncIYsbu; G_AUTHUSER_H=1; SPC_EC=\"QzJrb05KbXpxb2lBRVo2WV97kbZ+AviNH7A2MBEwT11hk6E7EVkCrKgdWbeEnP8PxNwXPF3Lp6bFKtfVo2VMVxcFOQ71TN1/QJ8QLFxKzGf2syED+fFoZlP4WQlQn59D06x3BHzETsU1cDjMav/ataN1PRe8pMBfMobdrXbeHjM=\"; SPC_U=661165014; SPC_ST=.UkhIdERnZ1d6SHQwZGs3et9xy0DmVL9CRDJK/0dXRmv6loBSpfkc4ORrfYhhKSOxxX38q7gBW22FOrqlKfEy498M8qWjfb886cXb0EZw4Ywh1tYUjbMFqfD5sGIG083HIrCxKv2EZO+Q6Oop0UGKPqhW9gDARXhWmuBU+yOtyPSJ6Tf2cTBH9IzX20gzozYFPp5w+O2GyHxMQX6RPnyAXQ==; _ga=GA1.1.254992489.1642585015; cto_bundle=A3tblV96N1d6bTZGTHUyQndoUFBxeGwlMkY1UWl4dVl0WEp5d0c0S0FhcmZlQjVFTU9pbkZPUEdLN2JVWkZMU0VoSjRkYUtRY3oxckRDJTJGZHlCTGpCbTk1V3pVbkZZUDE4NjkxN0VzUUxwVmtIQXpVSXl5ODElMkJFMzZQOXNicUh3SjVJcHhUUjZYJTJCcUFSejhkVjc3eVpmZWxPc096djdPcGJBdlVpRiUyQkt3RVNXN0FJVk0lMkJvOWZWcnolMkJ4RlJ5R1BLaDk1cG9PNw; SPC_T_IV=\"GwauGIVJnacOELC51U0QHA==\"; SPC_T_ID=\"kvSWD8RO9+DE34DXQ/wzhOjTC4jzV4Oa+W+cDapKPUdnn1VLuHc0zJ6zB3U2IKO5Ef8W+ruuaXaKqqXjtmzvjeoeqeaQbncrF46OqhV6Zx8=\"; SPC_R_T_ID=KgbUUQCcMPZorVjxLiFhrMktXZtvK7Gn0zWObXJD31O3OBcg3Q9PdKtzxaTdJYu0DZbfJGj4a8kVcpq9eUR9/EpH3DCQZOpN8n/dljpmy5A=; SPC_R_T_IV=nch4cZlc5ZPSa/N+HvEP7A==; SPC_T_ID=KgbUUQCcMPZorVjxLiFhrMktXZtvK7Gn0zWObXJD31O3OBcg3Q9PdKtzxaTdJYu0DZbfJGj4a8kVcpq9eUR9/EpH3DCQZOpN8n/dljpmy5A=; SPC_T_IV=nch4cZlc5ZPSa/N+HvEP7A==; spc_ckt_reqid=1f8a1b84d99bd13e8d68ca1212c84b00:0100014fba54ac24:000000a30ddfac25; shopee_webUnique_ccd=BDPlEFyr%2BmUwjpTQ0k8QHQ%3D%3D%7C%2FLk0lZCbjP6V7WI08zLBlGU6IK7wtwfD%2FV6wDVb3Mkyg7RJXcBeXGsihrSoBrOzrnmXf%2Bv%2F6SNeXIJi7VA6G4Q%3D%3D%7CKwN3iu4hrj6v0ek3%7C04%7C3; _ga_CB0044GVTM=GS1.1.1646638108.9.1.1646638137.31"
        ]
      )

    IO.inspect(url, label: "Craw data:")

    parse_location(response)
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

      _ ->
        []
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

  defp parse_location(response) do
    {:ok, results} = parse_response(response)

    # case results["error"] do
    #   e when e in [nil, 0] ->
    #     Enum.map(results["data"]["shop_categories"], fn cat ->
    #       category_id = cat["shop_category_id"]

    #       name = cat["display_name"]

    #       image = cat["image"]

    #       %{
    #         "name" => name,
    #         "image" => image,
    #         "category_id" => category_id,
    #         "slug" => "/category/#{category_id}"
    #       }
    #     end)

    #   _ ->
    #     []
    # end
  end

  defp parse_response(response) do
    case Floki.parse_document(response.body) do
      {:ok, document} ->
        Poison.decode(document)

      _ ->
        {:ok, %{:error => "Can't parse response"}}
    end
  end

  def craw_location() do
    {:ok, %{"data" => %{"divisions" => regions}}} =
      fetch_locations("https://shopee.ph/api/v4/location/get_child_division_list?division_id=0")

    regions =
      regions
      |> Enum.with_index(fn element, index -> Map.put(element, "db_id", index + 1) end)
      |> Enum.map(&Map.put(&1, "parent_id", "0"))
      |> IO.inspect(label: "Regions: ")

    export(regions, "regions.csv")

    result_provinces =
      Enum.reduce(regions, [], fn div, acc ->
        url = "https://shopee.ph/api/v4/location/get_child_division_list?division_id=#{div["id"]}"

        {:ok, %{"data" => %{"divisions" => provinces}}} = fetch_locations(url)

        (provinces
         |> Enum.with_index(fn element, index ->
           Map.put(element, "db_id", index + 1 + Enum.count(acc))
         end)
         |> Enum.map(&Map.put(&1, "parent_id", div["db_id"]))) ++ acc
      end)
      |> IO.inspect(label: "Provinces: ")

    export(result_provinces, "provinces.csv")

    result_cities =
      Enum.reduce(result_provinces, [], fn div, acc ->
        url = "https://shopee.ph/api/v4/location/get_child_division_list?division_id=#{div["id"]}"

        {:ok, %{"data" => %{"divisions" => cities}}} = fetch_locations(url)

        (cities
         |> Enum.with_index(fn element, index ->
           Map.put(element, "db_id", index + 1 + Enum.count(acc))
         end)
         |> Enum.map(&Map.put(&1, "parent_id", div["db_id"]))) ++ acc
      end)
      |> IO.inspect(label: "Cities: ")

    export(result_cities, "cities.csv")

    result_barangays =
      Enum.reduce(result_cities, [], fn div, acc ->
        url = "https://shopee.ph/api/v4/location/get_child_division_list?division_id=#{div["id"]}"

        {:ok, %{"data" => %{"divisions" => barangays}}} = fetch_locations(url)

        (barangays
         |> Enum.with_index(fn element, index ->
           Map.put(element, "db_id", index + 1 + Enum.count(acc))
         end)
         |> Enum.map(&Map.put(&1, "parent_id", div["db_id"]))) ++ acc
      end)
      |> IO.inspect(label: "Barangays: ")

    export(result_barangays, "barnagays.csv")
  end

  defp export(data, file_name) do
    {:ok, file} = File.open(file_name, [:write, :utf8])

    content =
      Enum.reduce(data, "", fn r, acc ->
        "#{r["db_id"]},#{r["division_name"]},#{r["parent_id"]}\n#{acc}"
      end)

    IO.write(file, content)

    File.close(file)
  end
end
