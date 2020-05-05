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
        live "/resources/new", AshDashboard.ResourcesNewLive, :resources_new, opts
        live "/resources/import", AshDashboard.ResourcesImportLive, :resources_import, opts
        live "/resource/:id", AshDashboard.ResourceLive, :resource, opts
        live "/data/", AshDashboard.DataLive, :data, opts
        live "/requests/", AshDashboard.RequestsLive, :requests, opts
        live "/admin/", AshDashboard.AdminLive, :admin, opts
        live "/docs/", AshDashboard.DocsLive, :docs, opts
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
