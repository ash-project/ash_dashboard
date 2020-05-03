defmodule AshDashboard.ResourceLive do
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

  defp fetch_resources(socket) do
    api =
      case socket.assigns.apis do
        [api] -> api
        _ -> raise "we don't support multiple APIs now"
      end

    IO.inspect(socket)
    resource =
      api
      |> Ash.resource()
      |> IO.inspect()
      |> Enum.filter(&String.contains?(Ash.name(&1), socket.assigns.params["id"]))

    assign(socket, resource: resource)
  end

  @impl true
  def handle_params(params, session, socket) do
    {:noreply,
     socket
     |> fetch_resources()}
  end

  @impl true
  def render(assigns) do
    ~L"""
      single resource 1
    """
  end
end
