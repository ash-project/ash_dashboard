defmodule AshDashboard.ColorBarComponentTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  alias AshDashboard.ColorBarComponent
  @endpoint AshDashboardTest.Endpoint

  @data [
    {"In use", 4.0, "purple", "unused"}
  ]

  describe "rendering" do
    test "color bar component" do
      result = render_component(ColorBarComponent, data: @data, title: "Hello")
      assert result =~ "bg-gradient-purple"
      assert result =~ "aria-valuenow=\"4.0\""
      assert result =~ "style=\"width: 4.0%\""
      assert result =~ "title=\"In use - 4.0%\""
      assert result =~ "<span class=\"progress-title\">Hello</span>"
      refute result =~ "unused"
    end
  end
end
