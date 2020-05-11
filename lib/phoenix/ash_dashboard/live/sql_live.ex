defmodule AshDashboard.SqlLive do
  use AshDashboard.Web, :live_view
  import AshDashboard.TableHelpers

  @impl true
  def mount(params, session, socket) do
    socket =
      socket
      |> assign_defaults(params, session)
      |> assign(:apis, session["apis"])
    {:ok, socket}
  end

  @impl true
  def handle_params(params, session, socket) do
    {:noreply, socket}
  end

  @impl true
  def render(assigns) do
    ~L"""
      SQL Playground
    """
  end

  @impl true
  def handle_event("validate", _, socket) do
    IO.inspect('validate event')  
    {:noreply, socket}
  end

  @impl true
  def handle_event("save", _, _csrf_token, socket) do
    IO.inspect('validate event')  
    {:noreply, socket}
  end
end
