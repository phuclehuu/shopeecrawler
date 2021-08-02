defmodule ShopeecrawlerWeb.PageControllerTest do
  use ShopeecrawlerWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "Welcome to Demo!"
  end
end
