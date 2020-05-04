defmodule AshDashboard.Router do
  @moduledoc """
  Provides LiveView routing for AshDashboard.
  """

  defmacro ash_dashboard(path, opts \\ []) do
    quote bind_quoted: binding() do
      scope path, alias: false, as: false do
        import Phoenix.LiveView.Router, only: [live: 4]

        opts = AshDashboard.Router.__options__(opts)
        live "/", AshDashboard.HomeLive, :home, opts
        live "/resources", AshDashboard.ResourcesLive, :resources, opts
        live "/resources/:id", AshDashboard.ResourceLive, :resource, opts
      end
    end
  end

  @doc false
  def __options__(options) do
    [
      session: {__MODULE__, :__session__, [options[:apis]]},
      layout: {AshDashboard.LayoutView, :dash},
      as: :ash_dashboard
    ]
  end

  @doc false
  def __session__(conn, apis) do
    %{"apis" => apis}
  end
end
