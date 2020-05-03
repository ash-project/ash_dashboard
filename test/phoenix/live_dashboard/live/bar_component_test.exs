defmodule AshDashboard.BarComponentTest do
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest

  alias AshDashboard.BarComponent
  @endpoint AshDashboardTest.Endpoint

  describe "rendering" do
    test "color bar component" do
      result =
        render_component(BarComponent,
          percent: 0.1,
          class: "test-class",
          inner_content: fn _ -> "123" end
        )

      assert result =~ "123"
      assert result =~ "style=\"width: 0.1%\""
      assert result =~ "div class=\"test-class\""
    end
  end
end
