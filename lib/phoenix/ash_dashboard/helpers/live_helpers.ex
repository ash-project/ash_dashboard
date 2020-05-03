defmodule AshDashboard.LiveHelpers do
  # General helpers for live views (not-rendering related).
  @moduledoc false

  @doc """
  Computes a route path to the live dashboard.
  """
  def ash_dashboard_path(socket, action, args \\ [], params \\ []) do
    apply(
      socket.router.__helpers__(),
      :ash_dashboard_path,
      [socket, action | args] ++ [params]
    )
  end

  @doc """
  Assign default values on the socket.
  """
  def assign_defaults(socket, params, session) do
    Phoenix.LiveView.assign(socket, :menu, %{
      action: socket.assigns.live_action
    })
  end
end
