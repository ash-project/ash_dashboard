defmodule AshDashboardTest do
  use ExUnit.Case, async: true

  import Phoenix.ConnTest
  @endpoint AshDashboardTest.Endpoint

  test "embeds phx-socket information" do
    assert build_conn() |> get("/dashboard/nonode@nohost") |> html_response(200) =~
             ~s|phx-socket="/live"|
  end
end
