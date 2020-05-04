defmodule AshDashboard.ResourceLive do
  use AshDashboard.Web, :live_view
  import AshDashboard.TableHelpers

  @impl true
  def mount(params, session, socket) do
    socket =
      socket
      |> assign_defaults(params, session)
      |> assign(:params, params)
      |> assign(:apis, session["apis"])
    {:ok, socket}
  end

  defp fetch_resource(socket) do
    api =
      case socket.assigns.apis do
        [api] -> api
        _ -> raise "we don't support multiple APIs now"
      end

    resource =
      api
      |> Ash.resources()
      |> IO.inspect()
      |> Enum.filter(&String.contains?(Ash.name(&1), socket.assigns.params["id"]))
      |> List.first()

    assign(socket, resource: resource)
  end

  @impl true
  def handle_params(params, session, socket) do
    {:noreply,
     socket
     |> fetch_resource()}
  end

  @impl true
  def render(assigns) do
    ~L"""
      <h2><%= Ash.name(@resource) %> Resource</h2>
      <%= live_redirect("Back", to: ash_dashboard_path(@socket, :resources), class: "menu-item") %>

      <%= f = form_for @resource, "#", [phx_change: :validate, phx_submit: :save, class: "resource"] %>
        <div class="form-row">
          <div class="form-group col-sm-4">
            <label for="inputName4">Name</label>
            <input type="text" class="form-control" id="inputName4" placeholder="Name" value="<%= @resource.name() %>">
          </div>
          <div class="form-group col-sm-2">
            <label for="inputType4">Type</label>
            <select name="node" class="custom-select" id="node-select">
              <option value="nonode@nohost" selected="">String</option>
              <option value="nonode@nohost" selected="">Integer</option>
              <option value="nonode@nohost" selected="">Boolean</option>
              <option value="nonode@nohost" selected="">Date</option>
            </select>
          </div>
          <div class="form-group col-sm-2">
            <label for="inputPrimaryKey4">Primary Key</label>
            <input type="text" class="form-control" id="inputPrimaryKey4" placeholder="PrimaryKey" value="<%= @resource.type() %>">
          </div>
          <div class="form-group col-sm-2">
            <label for="inputMaxPageSize4">Max Page Size</label>
            <input type="text" class="form-control" id="inputMaxPageSize4" placeholder="MaxPageSize" value="<%= @resource.max_page_size() %>">
          </div>
          <div class="form-group col-sm-2">
            <label for="inputDefaultPageSize4">Default Page Size</label>
            <input type="text" class="form-control" id="inputDefaultPageSize4" placeholder="DefaultPageSize" value="<%= @resource.default_page_size() %>">
          </div>
        </div>        
        <div class="form-row">
          <div class="form-group col-sm-3">
            <label for="inputName4">Name</label>
          </div>
          <div class="form-group col-sm-2">
          <label for="inputType4">Type</label>
          </div>
          <div class="form-group col-sm-1">
            <label for="inputName4">Allow Nil?</label>
          </div>
          <div class="form-group col-sm-1">
            <label for="inputName4">2</label>
          </div>
          <div class="form-group col-sm-1">
            <label for="inputName4">3</label>
          </div>
          <div class="form-group col-sm-1">
            <label for="inputName4">4</label>
          </div>
          <div class="form-group col-sm-1">
            <label for="inputName4">5</label>
          </div>
          <div class="form-group col-sm-1">
            <label for="inputName4">6</label>
          </div>
          <div class="form-group col-sm-1">
            <label for="inputName4">7</label>
          </div>
        </div>
        <%= for attribute <- @resource.attributes do %>
          <div class="form-row">
            <div class="form-group col-sm-3">
              <input type="text" class="form-control" id="inputName4" placeholder="Name" value="<%= attribute.name() %>">
            </div>
            <div class="form-group col-sm-2">
              <select name="node" class="custom-select" id="node-select">
                <option value="nonode@nohost" selected="">String</option>
                <option value="nonode@nohost" selected="">Integer</option>
                <option value="nonode@nohost" selected="">Boolean</option>
                <option value="nonode@nohost" selected="">Date</option>
              </select>
            </div>
            <div class="form-group col-sm-1">
              <input type="checkbox" id="gridCheck">
            </div>
            <div class="form-group col-sm-1">
              <input type="checkbox" id="gridCheck">
            </div>
            <div class="form-group col-sm-1">
              <input type="checkbox" id="gridCheck">
            </div>
            <div class="form-group col-sm-1">
              <input type="checkbox" id="gridCheck">
            </div>
            <div class="form-group col-sm-1">
              <input type="checkbox" id="gridCheck">
            </div>
            <div class="form-group col-sm-1">
              <input type="checkbox" id="gridCheck">
            </div>
            <div class="form-group col-sm-1">
              <input type="checkbox" id="gridCheck">
            </div>
          </div>
        <% end %>
      </form>
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
