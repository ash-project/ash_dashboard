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

    <%= for resource <- @resources do %>
      <%= f = form_for resource, "#", [phx_change: :validate, phx_submit: :save, class: "resource"] %>

        <section class="info">
          <h5>Info</h5>
          <div class="group">
            <%= label f, :name %>
            <input value="<%= resource.name() %>">
          </div>

          <div class="group">
            <%= label f, :type %>
            <input value="<%= resource.type() %>">
          </div>

          <div class="group">
            <%= label f, :max_page_size %>
            <input value="<%= resource.max_page_size() %>" type="number">
          </div>

          <div class="group">
            <%= label f, :default_page_size %>
            <input value="<%= resource.default_page_size() %>" type="number">
          </div>

          <div class="group">
            <%= label f, :primary_key %>
              <input value="<%= List.first(resource.primary_key()) |> Atom.to_string() %>">
            </div>
        </section>

        <section class="attributes">
          <h5>Attributes</h5>
          <%= for attribute <- resource.attributes do %>
            <div class="group">
              <%= label f, attribute.name %>
              <input>
            </div>
          <% end %>
        </section>

        <section class="actions">
          <h5>Actions</h5>
          <%= for action <- resource.actions do %>
            <div class="group">
              <%= label f, action.name %>
              <input>
            </div>
            <div class="group">
              <%= label f, action.type %>
              <input>
            </div>

            <%= if action.type == :read do %>
              <div class="group">
                <%= label f, action.paginate? %>
                <input type="checkbox">
              </div>
            <% end %>
      
            <div class="group">
              <%= label f, action.primary? %>
              <input type="checkbox">
            </div>

            <%= for rule <- action.rules do %>
              RULE!
            <% end %>
          <% end %>
        </section>
      </form>





      <br>
      <br>
      <br>
      <br>
      <br>
      <br>
      <br>
      <br>
      <br>
      <br>
      <br>
      <br>
      <br>
      <br>
      <br>
      <br>
      <br>
      <br>
      <br>
      <br>
      <br>
      <br>
      <br>
      <br>
      <br>
      <br>
      <br>
      <br>
      <br>
      <br>
      <% end %>
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

# <h2><%= @title %></h2>

# <%= f = form_for @changeset, "#",
#   id: "resource-form",
#   phx_target: @myself,
#   phx_change: "validate",
#   phx_submit: "save" %>

#   <%= label f, :name %>
#   <%= text_input f, :name %>
#   <%= error_tag f, :name %>

#   <%= label f, :type %>
#   <%= text_input f, :type %>
#   <%= error_tag f, :type %>

#   <%= label f, :max_page_size %>
#   <%= number_input f, :max_page_size %>
#   <%= error_tag f, :max_page_size %>

#   <%= label f, :default_page_size %>
#   <%= number_input f, :default_page_size %>
#   <%= error_tag f, :default_page_size %>

#   <%= label f, :primary_key %>
#   <%= checkbox f, :primary_key %>
#   <%= error_tag f, :primary_key %>

#   <h1>Attributes</h1>

#   <%= inputs_for f, :attributes, fn i -> %>
#     <div class="form-group">
#       <%= label i, :name, "Bar ##{i.index + 1}", class: "control-label" %>
#       <%= text_input i, :name, class: "form-control" %>
#     </div>
#   <% end %>

#   <%= submit "Save", phx_disable_with: "Saving..." %>
# </form>
