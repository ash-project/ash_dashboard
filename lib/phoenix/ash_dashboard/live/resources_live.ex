defmodule AshDashboard.ResourcesLive do
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
    %{search: search, sort_by: sort_by, sort_dir: sort_dir, limit: limit} = socket.assigns.params

    api =
      case socket.assigns.apis do
        [api] -> api
        _ -> raise "we don't support multiple APIs now"
      end

    resources =
      api
      |> Ash.resources()
      |> Enum.filter(&String.contains?(Ash.name(&1), search || ""))
      |> Enum.sort_by(
        fn resource ->
          case sort_by do
            :name -> Ash.name(resource)
            :type -> Ash.type(resource)
          end
        end,
        sort_dir
      )

    total = Enum.count(resources)
    limited_resources = Enum.take(resources, limit)

    assign(socket, resources: limited_resources, total: total)
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
    <div class="tabular-page">
    <h5 class="card-title">Resources</h5>
    <div class="tabular-search">
    <form phx-change="search" phx-submit="search" class="form-inline">
      <div class="form-row align-items-center">
        <div class="col-auto">
          <input type="search" name="search" class="form-control form-control-sm" value="<%= @params.search %>" placeholder="Search by name" phx-debounce="300">
        </div>
      </div>
    </form>
    </div>
    <form phx-change="select_limit" class="form-inline">
    <div class="form-row align-items-center">
      <div class="col-auto">Showing at most</div>
      <div class="col-auto">
        <div class="input-group input-group-sm">
          <select name="limit" class="custom-select" id="limit-select">
            <%= options_for_select(limit_options(), @params.limit) %>
          </select>
        </div>
      </div>
      <div class="col-auto">
        resources out of <%= @total %>
      </div>
    </div>
    </form>
    <div class="card tabular-card mb-4 mt-4">
    <div class="card-body p-0">
      <div class="dash-table-wrapper">
        <table class="table table-hover mt-0 dash-table clickable-rows">
          <thead>
            <tr>
              <th class="pl-4">
                <%= sort_link(@socket, @live_action, @menu, @params, :name, "Name") %>
              </th>
              <th>
                <%= sort_link(@socket, @live_action, @menu, @params, :type, "Type") %>
              </th>
            </tr>
          </thead>
          <tbody>
            <%= for resource <- @resources do %>
              <tr phx-click="show_info" phx-value-name="<%= Ash.name(resource) %>" phx-page-loading>
                <td class="tabular-column-name pl-4"><%= Ash.name(resource) %></td>
                <td class="text-right"><%= Ash.type(resource) %></td>
              </tr>
            <% end %>
          </tbody>
        </table>
      </div>
    </div>
    </div>
    </div>
    """
  end

  @impl true
  def handle_event("validate", _, socket) do
    {:noreply, socket}
  end

  def handle_event("show_info", %{"name" => name}, socket) do
    {:noreply, push_redirect(socket, to: ash_dashboard_path(socket, :resource, [], name))}
  end

  @impl true
  def handle_event("save", _, _csrf_token, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("search", %{"search" => search}, socket) do
    %{menu: menu, params: params} = socket.assigns
    {:noreply, push_patch(socket, to: self_path(socket, %{params | search: search}))}
  end

  def handle_event("select_limit", %{"limit" => limit}, socket) do
    %{menu: menu, params: params} = socket.assigns
    {:noreply, push_patch(socket, to: self_path(socket, %{params | limit: limit}))}
  end

  defp self_path(socket, params) do
    ash_dashboard_path(socket, :resources, [], params)
  end
end
