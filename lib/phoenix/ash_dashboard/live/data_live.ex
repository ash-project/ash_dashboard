defmodule AshDashboard.DataLive do
  use AshDashboard.Web, :live_view
  import AshDashboard.TableHelpers

  @sort_by ~w(name type)

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

    resources = Ash.resources(api)
    assign(socket, resources: resources)
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply,
     socket
     |> assign_params(params, @sort_by)
     |> fetch_resources()}
  end

  @impl true
  def render(assigns) do
    ~L"""
      Data page

      <div class="code">HI THERE</div>
      <%= for resource <- @resources do %>
        <%= Ash.name(resource) %>
      <% end %>

      <div class="row">
        <div class="container">
          <ul class="nav nav-tabs mb-4 charts-nav">
            <li class="nav-item">
              Data 1
            </li>
            <li class="nav-item">
              Data 2
            </li>
            <li class="nav-item">
              Data 3
            </li>
            <li class="nav-item">
              Data 4
            </li>
          </ul>
        </div>
      </div>
    """
  end
end
