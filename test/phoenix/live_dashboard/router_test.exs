defmodule AshDashboard.RouterTest do
  use ExUnit.Case, async: true

  alias AshDashboard.Router

  test "sets options" do
    assert Router.__options__([]) == [
             session: {AshDashboard.Router, :__session__, [nil]},
             layout: {AshDashboard.LayoutView, :dash},
             as: :ash_dashboard
           ]
  end

  test "normalizes metrics option" do
    assert Router.__options__(metrics: Foo)[:session] ==
             {AshDashboard.Router, :__session__, [{Foo, :metrics}]}

    assert Router.__options__(metrics: {Foo, :bar})[:session] ==
             {AshDashboard.Router, :__session__, [{Foo, :bar}]}

    assert_raise ArgumentError, fn ->
      Router.__options__(metrics: [])
    end
  end
end
