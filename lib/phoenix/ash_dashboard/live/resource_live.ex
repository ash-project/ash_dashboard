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
      <%= f = form_for @resource, "#", [phx_change: :validate, phx_submit: :save, class: "resource"] %>
        <div class="form-row">
          <div class="form-group col-sm-12">
            <div class="form-section-heading">Information</div>
          </div>
        </div>
        <div class="form-row">
          <div class="form-group col-sm-4">
            <label for="inputName4">Name</label>
            <input type="text" class="form-control" id="inputName4" placeholder="Name" value="<%= Ash.name(@resource) %>">
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
            <input type="text" class="form-control" id="inputPrimaryKey4" placeholder="PrimaryKey" value="<%= Ash.type(@resource) %>">
          </div>
          <div class="form-group col-sm-2">
            <label for="inputMaxPageSize4">Max Page Size</label>
            <input type="text" class="form-control" id="inputMaxPageSize4" placeholder="MaxPageSize" value="<%= Ash.max_page_size(@resource) %>">
          </div>
          <div class="form-group col-sm-2">
            <label for="inputDefaultPageSize4">Default Page Size</label>
            <input type="text" class="form-control" id="inputDefaultPageSize4" placeholder="DefaultPageSize" value="<%= Ash.default_page_size(@resource) %>">
          </div>
        </div>        
        <div class="form-row">
          <div class="form-group col-sm-12">
            <div class="form-section-heading">Attributes</div>
          </div>
        </div>
        <div class="form-row">
          <div class="form-group col-sm-2">
            <label for="inputName4">Name</label>
          </div>
          <div class="form-group col-sm-1">
          <label for="inputType4">Type</label>
          </div>
          <div class="form-group col-sm-1">
            <label for="inputName4">Allow Nil?</label>
          </div>
          <div class="form-group col-sm-1">
            <label for="inputName4">Generated?</label>
          </div>
          <div class="form-group col-sm-1">
            <label for="inputName4">Primary Key?</label>
          </div>
          <div class="form-group col-sm-1">
            <label for="inputName4">Writable?</label>
          </div>
          <div class="form-group col-sm-1">
            <label for="inputName4">default</label>
          </div>
          <div class="form-group col-sm-2">
            <label for="inputName4">Update Default</label>
          </div>
          <div class="form-group col-sm-2">
            <label for="inputName4">Write Rules</label>
          </div>
        </div>
        <%= for attribute <- @resource.attributes do %>
          <div class="form-row">
            <div class="form-group col-sm-2">
              <input type="text" class="form-control" id="inputName4" placeholder="Name" value="<%= attribute.name() %>">
            </div>
            <div class="form-group col-sm-1">
              <select name="node" class="custom-select" id="node-select">
                <option value="nonode@nohost" selected="">String</option>
                <option value="nonode@nohost" selected="">Integer</option>
                <option value="nonode@nohost" selected="">Boolean</option>
                <option value="nonode@nohost" selected="">Date</option>
              </select>
            </div>
            <div class="form-group col-sm-1">
              <input type="checkbox" id="gridCheck" checked=<%= attribute.allow_nil?() %>>
            </div>
            <div class="form-group col-sm-1">
              <input type="checkbox" id="gridCheck" checked=<%= attribute.generated?() %>>
            </div>
            <div class="form-group col-sm-1">
              <input type="checkbox" id="gridCheck" checked=<%= attribute.primary_key?() %>>
            </div>
            <div class="form-group col-sm-1">
              <input type="checkbox" id="gridCheck" checked=<%= attribute.writable?() %>>
            </div>
            <div class="form-group col-sm-1">
              <input type="text" class="form-control" id="inputName4" placeholder="Name" value="<%= inspect(attribute.default) %> ">
            </div>
            <div class="form-group col-sm-2">
              <input type="text" class="form-control" id="inputName4" placeholder="Name" value="<%= inspect(attribute.update_default) %> ">
            </div>
            <div class="form-group col-sm-2">
              <input type="text" class="form-control" id="inputName4" placeholder="Name" value="<%= attribute.write_rules() %>">
            </div>
          </div>
        <% end %>
      </form>
      <div class="form-row">
        <div class="form-group col-sm-11">
          <%= live_redirect("Back", to: ash_dashboard_path(@socket, :resources), class: "menu-item") %>
        </div>
        <div class="form-group col-sm-1">
          <button type="submit" class="btn btn-primary">Submit</button>
        </div>
      </div>


      <br>
      <br>
      <br>
      <br>
      <br>
      <br>
      <br>


      <div class="container">
        <div class="row">
          <div class="col">
            1 of 2
          </div>
          <div class="col">
            2 of 2
          </div>
        </div>
        <div class="row">
          <div class="col">
            1 of 3
          </div>
          <div class="col">
            2 of 3
          </div>
          <div class="col">
            3 of 3
          </div>
        </div>
      </div>
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
