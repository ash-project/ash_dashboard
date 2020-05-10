defmodule AshDashboard.RequestsLive do
  use AshDashboard.Web, :live_view
  import AshDashboard.TableHelpers

  @sort_by ~w(name type)

  @impl true
  def mount(params, session, socket) do
    socket =
      socket
      |> assign_defaults(params, session)
      |> assign(:apis, session["apis"])
      |> assign(:operation, nil)
      |> assign(:primary_resource, nil)
      |> assign(:relationship_resource, nil)
      |> assign(:primary_data_type, "Collection")
      |> assign(:foo, "bar")
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
    # assign(socket, resource: List.first(resources))
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
      <div class="card mb-5">
        <div class="card-header">
          Request
        </div>
        <div class="card-body">
          <div class="container">
            <div class="row mb-3 justify-content-between">
              <div class="col-1">
                <p class="font-weight-bold">URL</p>
              </div>
              <div class="col-7">
                <span class="api-name">
                  <%= base_url %>
                </span>
                <div class="select2" phx-hook="SelectPrimaryResource" phx-update="ignore">
                  <select id="select-primary-resource">
                    <option value=""></option>
                    <%= for r <- @resources do %>
                      <option value="<%= Ash.name(r) %>">
                        <%= Ash.name(r) %>
                      </option>
                    <% end %>
                  </select>
                </div>
                <%= if @primary_data_type == "Item" || @primary_data_type == "Relationship" do %>
                  <span>/</span>
                  <input class="primary-resource-id" placeholder="id">
                <% end %>
                <%= if @primary_data_type == "Relationship" do %>
                  <span>/</span>
                  <div class="select2" phx-hook="SelectRelationshipResource" phx-update="ignore">
                    <select id="select-relationship-resource">
                      <option value=""></option>
                      <%= for r <- @resources do %>
                        <option value="<%= Ash.name(r) %>">
                          <%= Ash.name(r) %>
                        </option>
                      <% end %>
                    </select>
                  </div>
                <% end %>
              </div>
              <div class="col-4">
                <div class="btn-group" role="group" aria-label="Basic example">
                  <button type="button" class="btn btn-outline-secondary <%= if @primary_data_type == "Item" do "active" end %>" phx-click="select_primary_data_type" phx-value-type="Item">Item</button>
                  <button type="button" class="btn btn-outline-secondary <%= if @primary_data_type == "Collection" do "active" end %>" phx-click="select_primary_data_type" phx-value-type="Collection">Collection</button>
                  <button type="button" class="btn btn-outline-secondary <%= if @primary_data_type == "Relationship" do "active" end %>" phx-click="select_primary_data_type" phx-value-type="Relationship">Relationship</button>
                </div>      
              </div>
            </div>
            <div class="row pt-3 mb-3 border-top">
              <div class="col-1">
                <p class="font-weight-bold">Action</p>
              </div>
              <div class="col-11">
                <button type="button" class="btn btn-outline-primary <%= if @operation == "GET" do "active" end %>" phx-click="select_operation" phx-value-name="GET">GET</button>
                <button type="button" class="btn btn-outline-primary <%= if @operation == "INDEX" do "active" end %>" phx-click="select_operation" phx-value-name="INDEX">INDEX</button>
                <button type="button" class="btn btn-outline-success <%= if @operation == "CREATE" do "active" end %>" phx-click="select_operation" phx-value-name="CREATE">CREATE</button>
                <button type="button" class="btn btn-outline-warning <%= if @operation == "UPDATE" do "active" end %>" phx-click="select_operation" phx-value-name="UPDATE">UPDATE</button>
                <button type="button" class="btn btn-outline-warning <%= if @operation == "SHIP" do "active" end %>" phx-click="select_operation" phx-value-name="SHIP">SHIP</button>
                <button type="button" class="btn btn-outline-warning <%= if @operation == "COMPLETE" do "active" end %>" phx-click="select_operation" phx-value-name="COMPLETE">COMPLETE</button>
                <button type="button" class="btn btn-outline-danger <%= if @operation == "DESTROY" do "active" end %>" phx-click="select_operation" phx-value-name="DESTROY">DESTROY</button>
              </div>
            </div>
            <div class="row pt-3 mb-3 border-top">
              <div class="col-1">
                <p class="font-weight-bold">Options</p>
              </div>
              <div class="col-6">
                N/A
              </div>
            </div>
            <div class="row pt-3 mb-3 border-top">
              <div class="col-1">
                <p class="font-weight-bold">Ash</p>
              </div>
              <div class="col-11" phx-hook="HighlightCode" phx-ignore=true>
                <pre><code class="language-elixir"><%= ash_output(@operation, @primary_resource, @relationship_resource) %></code></pre>
              </div>
            </div>
            <div class="row pt-3 mb-3 border-top">
              <div class="col-11 offset-11">
                <a href="#" class="btn btn-primary">Send</a>
              </div>
            </div>
          </div>
        </div>
      </div>

      <div class="card">
        <div class="card-header">
          Response
        </div>
        <div class="card-body">
          <div class="container">       
            <div class="row mb-3">
              <div class="col">              
                Data
                <table class="table">
                  <thead>
                    <tr>
                      <th scope="col">#</th>
                      <th scope="col">First</th>
                      <th scope="col">Last</th>
                      <th scope="col">Handle</th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr>
                      <th scope="row">1</th>
                      <td>Mark</td>
                      <td>Otto</td>
                      <td>@mdo</td>
                    </tr>
                    <tr>
                      <th scope="row">2</th>
                      <td>Jacob</td>
                      <td>Thornton</td>
                      <td>@fat</td>
                    </tr>
                    <tr>
                      <th scope="row">3</th>
                      <td>Larry</td>
                      <td>the Bird</td>
                      <td>@twitter</td>
                    </tr>
                  </tbody>
                </table>
              </div>
              <div class="col">   
                JSON Output
                <div phx-hook="HighlightCode" phx-ignore=true>
                  <pre>
                    <code class="language-json">
<%= json %>
                    </code>
                  </pre>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    """
  end

  def handle_event("select_primary_data_type", %{"type" => type}, socket) do
    IO.inspect("select_primary_data_type: #{type}")
    {:noreply, assign(socket, primary_data_type: type)}
  end

  def handle_event("select_operation", %{"name" => name}, socket) do
    IO.inspect("select_operation: #{name}")
    {:noreply, assign(socket, operation: name)}
  end

  def handle_event("primary_resource_selected", %{"primary_resource" => name}, socket) do
    IO.inspect("primary_resource_selected: #{name}")
    {:noreply, assign(socket, primary_resource: name)}
  end

  def handle_event("relationship_resource_selected", %{"relationship_resource" => name}, socket) do
    IO.inspect("relationship_resource_selected: #{name}")
    {:noreply, assign(socket, relationship_resource: name)}
  end

  def base_url do
   "https://myapp.com/api/"
  end
  
  def json do
    ~s"""
    {
      "data": {
          "attributes": {
              "created_at": "2020-03-25T01:34:20Z",
              "short_name": "Hogwarts",
              "updated_at": "2020-03-25T01:34:20Z",
          },
          "id": 1,
          "links": {},
          "relationships": {},
          "type": "school"
      },
      "jsonapi": {
          "version": "1.0"
      },
      "links": {
          "self": "http://localhost:4000/ash-api/educators/2/school?include=educators"
      }
    }
    """
  end

  def ash_output(operation, primary_resource, relationship_resource) do
    IO.inspect("ash_output/1b")
 
    app_name = "MyApp"
    api_name = app_name <> ".Api"
    op = String.downcase(operation || "OPERATION")
    primary_resource = app_name <> "." <> String.capitalize(primary_resource || "RESOURCE")
    relationship_resource = app_name <> "." <> String.capitalize(relationship_resource || "RESOURCE")

    api_name <> "." <> op <> "(" <> primary_resource <> ")" <> " and relationship: " <> relationship_resource
  end
end



# <%= if @operation == "GET" do %>
# <div class="row mb-3">
#   <div class="col">
#     GET construct url
#   </div>
#   <div class="col">
#     GET pretty output of url
#   </div>
# </div>
# <% else %>
# <div class="row mb-3">
#   <div class="col">
#     construct url
#   </div>
#   <div class="col">
#     pretty output of url
#   </div>
# </div>
# <% end %>