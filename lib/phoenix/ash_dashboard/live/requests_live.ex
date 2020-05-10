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
      |> assign(:resource, nil)
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
      <h1>JSON API Explorer</h1>
      <div class="card">
        <div class="card-body">
          <div class="container">
            <div class="row mb-3">
              <div class="col">
                <div class="btn-group" role="group" aria-label="Basic example">
                  <button type="button" class="btn btn-secondary">Resource</button>
                  <button type="button" class="btn btn-secondary">Collection</button>
                  <button type="button" class="btn btn-secondary">Relationship Collection</button>
                </div>      
              </div>
              <div class="col">
                <div class="select2" phx-hook="SelectResource" phx-update="ignore">
                  <select name="resource">
                    <option value="">Choose Primary Data Source</option>
                    <%= for r <- @resources do %>
                      <option value="<%= Ash.name(r) %>">
                        <%= Ash.name(r) %>
                      </option>
                    <% end %>
                  </select>
                </div>
              </div>
            </div>
            <div class="row mb-3">
              <div class="col">
                <button type="button" class="btn btn-outline-primary <%= if @operation == "GET" do "active" end %>" phx-click="select_operation" phx-value-name="GET">GET</button>
                <button type="button" class="btn btn-outline-primary <%= if @operation == "INDEX" do "active" end %>" phx-click="select_operation" phx-value-name="INDEX">INDEX</button>
                <button type="button" class="btn btn-outline-success <%= if @operation == "CREATE" do "active" end %>" phx-click="select_operation" phx-value-name="CREATE">CREATE</button>
                <button type="button" class="btn btn-outline-warning <%= if @operation == "UPDATE" do "active" end %>" phx-click="select_operation" phx-value-name="UPDATE">UPDATE</button>
                <button type="button" class="btn btn-outline-warning <%= if @operation == "SHIP" do "active" end %>" phx-click="select_operation" phx-value-name="SHIP">SHIP</button>
                <button type="button" class="btn btn-outline-warning <%= if @operation == "COMPLETE" do "active" end %>" phx-click="select_operation" phx-value-name="COMPLETE">COMPLETE</button>
                <button type="button" class="btn btn-outline-danger <%= if @operation == "DESTROY" do "active" end %>" phx-click="select_operation" phx-value-name="DESTROY">DESTROY</button>
              </div>
            </div>
            <%= if @operation == "GET" do %>
              <div class="row mb-3">
                <div class="col">
                  GET construct url
                </div>
                <div class="col">
                  GET pretty output of url
                </div>
              </div>
            <% else %>
              <div class="row mb-3">
                <div class="col">
                  construct url
                </div>
                <div class="col">
                  pretty output of url
                </div>
              </div>
            <% end %>
            <div class="row mb-3">
              <div class="col" phx-hook="HighlightCode" phx-ignore=true>
                Ash Equivilant
                <pre>
                  <code class="language-elixir">
<%= ash_output(@operation, @resource) %>
                  </code>
                </pre>
              </div>
            </div>
            <div class="row mb-3">
              <div class="col">
                <a href="#" class="btn btn-primary">Send</a>
              </div>
            </div>
            <div class="row mb-3">
              <div class="col">              
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
  
  def handle_event("select_operation", %{"name" => name}, socket) do
    IO.inspect("select_operation: #{name}")
    {:noreply, assign(socket, operation: name)}
  end

  def handle_event("resource_selected", %{"resource" => name}, socket) do
    IO.inspect("resource_selected: #{name}")
    IO.inspect(name)
    IO.inspect("resource_selected")

    {:noreply, assign(socket, resource: name)}
  end

  def ash_output(operation, resource) do
    IO.inspect("ash_output/1b")
 
    app_name = "MyApp"
    api_name = app_name <> ".Api"
    op = String.downcase(operation || "OPERATION")
    resource = app_name <> "." <> String.upcase(resource || "RESOURCE")

    api_name <> "." <> op <> "(" <> resource <> ")"
  end
end
