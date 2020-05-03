defmodule AshDashboard.HomeLive do
  use AshDashboard.Web, :live_view

  @impl true
  def mount(params, session, socket) do
    socket = assign_defaults(socket, params, session)
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~L"""
    <h1>Hello World</h1>
    """
  end
end
