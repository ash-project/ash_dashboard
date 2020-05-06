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
    <div class="form-row">
      <div class="form-group col-sm-10">
        <h2>Resources</h2>
      </div>
      <div class="form-group col-sm-1">
        <button phx-click="new" class="btn btn-primary">New</button>
      </div>
      <div class="form-group col-sm-1">
        <button phx-click="import" class="btn btn-primary">Import</button>
      </div>
    </div>
    <div class="tabular-page">
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









    <div class="card">
    <div class="card-header">
      <h1>School</h1>
    </div>
    <div class="card-body">
      <h6 class="card-title">Optional Descrption</h5>
      <div class="row">
        <div class="col-sm-2">
          <div class="card mb-4">
            <div class="card-body">
              <h5 class="card-title text-center">Attributes</h5>
              <h1 class="text-center font-weight-bold text-primary">27</h1>
            </div>
          </div>
          <div class="card">
            <div class="card-body text-center">
              <h5 class="card-title">Functions</h5>
              <h1 class="text-center font-weight-bold text-primary">11</h1>
            </div>
          </div>

        </div>

        <div class="col-sm-2">
          <div class="card mb-4">
            <div class="card-body">
              <h5 class="card-title text-center">Computed</h5>
              <h1 class="text-center font-weight-bold text-primary">3</h1>
            </div>
          </div>
          <div class="card">
            <div class="card-body">
              <h5 class="card-title text-center">Aggregates</h5>
              <h1 class="text-center font-weight-bold text-primary">18</h1>
            </div>
          </div>
        </div>

        <div class="col-sm-2">
          <div class="card mb-4">
            <div class="card-body">
              <h5 class="card-title text-center">Queries</h5>
              <h1 class="text-center font-weight-bold text-primary">4</h1>
            </div>
          </div>
          <div class="card">
            <div class="card-body text-center">
              <h5 class="card-title">Source</h5>
              <h1 class="text-center font-weight-bold text-primary">PG</h1>
            </div>
          </div>
        </div>






        <div class="col-sm-6">
          <div class="card">
            <div class="card-body">
              <table class="table font-weight-light table-sm table-borderless action-support">
                <thead>
                  <tr>
                    <th scope="col"></th>
                    <th scope="col" >JSON:API</th>
                    <th scope="col">GraphQL</th>
                    <th scope="col">gRPC</th>
                    <th scope="col">PDF</th>
                    <th scope="col">CSV</th>
                  </tr>
                </thead>
                <tbody>
                  <tr class="border-bottom">
                    <th scope="row">Create</th>
                    <td>
                      <svg class="circle-check" id="Layer_1" style="enable-background:new 0 0 612 792;" version="1.1" viewBox="0 0 612 792" xml:space="preserve" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink"><style type="text/css">
                        .st0{clip-path:url(#SVGID_2_);fill:none;stroke:#41AD49;stroke-width:32;}
                        .st1{fill:#41AD49;}
                      </style><g><g><defs><rect height="512" id="SVGID_1_" width="512" x="50" y="140"/></defs><clipPath id="SVGID_2_"><use style="overflow:visible;" xlink:href="#SVGID_1_"/></clipPath><path class="st0" d="M306,629.5c128.8,0,233.5-104.7,233.5-233.5S434.8,162.5,306,162.5S72.5,267.2,72.5,396    S177.2,629.5,306,629.5L306,629.5z"/></g><polygon class="st1" points="421.4,271 241.9,450.5 174.9,383.5 122,436.4 241.9,556.2 257.3,540.8 257.4,540.8 474.3,323.9    421.4,271  "/></g></svg>
                    </td>
                    <td>
                      <svg class="circle-check" id="Layer_1" style="enable-background:new 0 0 612 792;" version="1.1" viewBox="0 0 612 792" xml:space="preserve" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink"><style type="text/css">
                        .st0{clip-path:url(#SVGID_2_);fill:none;stroke:#41AD49;stroke-width:32;}
                        .st1{fill:#41AD49;}
                      </style><g><g><defs><rect height="512" id="SVGID_1_" width="512" x="50" y="140"/></defs><clipPath id="SVGID_2_"><use style="overflow:visible;" xlink:href="#SVGID_1_"/></clipPath><path class="st0" d="M306,629.5c128.8,0,233.5-104.7,233.5-233.5S434.8,162.5,306,162.5S72.5,267.2,72.5,396    S177.2,629.5,306,629.5L306,629.5z"/></g><polygon class="st1" points="421.4,271 241.9,450.5 174.9,383.5 122,436.4 241.9,556.2 257.3,540.8 257.4,540.8 474.3,323.9    421.4,271  "/></g></svg>
                    </td>
                    <td></td>
                    <td></td>
                    <td>
                      <svg class="circle-check" id="Layer_1" style="enable-background:new 0 0 612 792;" version="1.1" viewBox="0 0 612 792" xml:space="preserve" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink"><style type="text/css">
                        .st0{clip-path:url(#SVGID_2_);fill:none;stroke:#41AD49;stroke-width:32;}
                        .st1{fill:#41AD49;}
                      </style><g><g><defs><rect height="512" id="SVGID_1_" width="512" x="50" y="140"/></defs><clipPath id="SVGID_2_"><use style="overflow:visible;" xlink:href="#SVGID_1_"/></clipPath><path class="st0" d="M306,629.5c128.8,0,233.5-104.7,233.5-233.5S434.8,162.5,306,162.5S72.5,267.2,72.5,396    S177.2,629.5,306,629.5L306,629.5z"/></g><polygon class="st1" points="421.4,271 241.9,450.5 174.9,383.5 122,436.4 241.9,556.2 257.3,540.8 257.4,540.8 474.3,323.9    421.4,271  "/></g></svg>
                    </td>
                  </tr>
                  <tr class="border-bottom">
                    <th scope="row">Read</th>
                    <td>
                      <svg class="circle-check" id="Layer_1" style="enable-background:new 0 0 612 792;" version="1.1" viewBox="0 0 612 792" xml:space="preserve" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink"><style type="text/css">
                        .st0{clip-path:url(#SVGID_2_);fill:none;stroke:#41AD49;stroke-width:32;}
                        .st1{fill:#41AD49;}
                      </style><g><g><defs><rect height="512" id="SVGID_1_" width="512" x="50" y="140"/></defs><clipPath id="SVGID_2_"><use style="overflow:visible;" xlink:href="#SVGID_1_"/></clipPath><path class="st0" d="M306,629.5c128.8,0,233.5-104.7,233.5-233.5S434.8,162.5,306,162.5S72.5,267.2,72.5,396    S177.2,629.5,306,629.5L306,629.5z"/></g><polygon class="st1" points="421.4,271 241.9,450.5 174.9,383.5 122,436.4 241.9,556.2 257.3,540.8 257.4,540.8 474.3,323.9    421.4,271  "/></g></svg>
                    </td>
                    <td></td>
                    <td></td>
                    <td>
                      <svg class="circle-check" id="Layer_1" style="enable-background:new 0 0 612 792;" version="1.1" viewBox="0 0 612 792" xml:space="preserve" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink"><style type="text/css">
                        .st0{clip-path:url(#SVGID_2_);fill:none;stroke:#41AD49;stroke-width:32;}
                        .st1{fill:#41AD49;}
                      </style><g><g><defs><rect height="512" id="SVGID_1_" width="512" x="50" y="140"/></defs><clipPath id="SVGID_2_"><use style="overflow:visible;" xlink:href="#SVGID_1_"/></clipPath><path class="st0" d="M306,629.5c128.8,0,233.5-104.7,233.5-233.5S434.8,162.5,306,162.5S72.5,267.2,72.5,396    S177.2,629.5,306,629.5L306,629.5z"/></g><polygon class="st1" points="421.4,271 241.9,450.5 174.9,383.5 122,436.4 241.9,556.2 257.3,540.8 257.4,540.8 474.3,323.9    421.4,271  "/></g></svg>
                    </td>
                    <td>
                      <svg class="circle-check" id="Layer_1" style="enable-background:new 0 0 612 792;" version="1.1" viewBox="0 0 612 792" xml:space="preserve" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink"><style type="text/css">
                        .st0{clip-path:url(#SVGID_2_);fill:none;stroke:#41AD49;stroke-width:32;}
                        .st1{fill:#41AD49;}
                      </style><g><g><defs><rect height="512" id="SVGID_1_" width="512" x="50" y="140"/></defs><clipPath id="SVGID_2_"><use style="overflow:visible;" xlink:href="#SVGID_1_"/></clipPath><path class="st0" d="M306,629.5c128.8,0,233.5-104.7,233.5-233.5S434.8,162.5,306,162.5S72.5,267.2,72.5,396    S177.2,629.5,306,629.5L306,629.5z"/></g><polygon class="st1" points="421.4,271 241.9,450.5 174.9,383.5 122,436.4 241.9,556.2 257.3,540.8 257.4,540.8 474.3,323.9    421.4,271  "/></g></svg>
                    </td>
                  </tr>
                  <tr class="border-bottom">
                    <th scope="row">Update</th>
                    <td>
                      <svg class="circle-check" id="Layer_1" style="enable-background:new 0 0 612 792;" version="1.1" viewBox="0 0 612 792" xml:space="preserve" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink"><style type="text/css">
                        .st0{clip-path:url(#SVGID_2_);fill:none;stroke:#41AD49;stroke-width:32;}
                        .st1{fill:#41AD49;}
                      </style><g><g><defs><rect height="512" id="SVGID_1_" width="512" x="50" y="140"/></defs><clipPath id="SVGID_2_"><use style="overflow:visible;" xlink:href="#SVGID_1_"/></clipPath><path class="st0" d="M306,629.5c128.8,0,233.5-104.7,233.5-233.5S434.8,162.5,306,162.5S72.5,267.2,72.5,396    S177.2,629.5,306,629.5L306,629.5z"/></g><polygon class="st1" points="421.4,271 241.9,450.5 174.9,383.5 122,436.4 241.9,556.2 257.3,540.8 257.4,540.8 474.3,323.9    421.4,271  "/></g></svg>
                    </td>
                    <td>
                      <svg class="circle-check" id="Layer_1" style="enable-background:new 0 0 612 792;" version="1.1" viewBox="0 0 612 792" xml:space="preserve" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink"><style type="text/css">
                        .st0{clip-path:url(#SVGID_2_);fill:none;stroke:#41AD49;stroke-width:32;}
                        .st1{fill:#41AD49;}
                      </style><g><g><defs><rect height="512" id="SVGID_1_" width="512" x="50" y="140"/></defs><clipPath id="SVGID_2_"><use style="overflow:visible;" xlink:href="#SVGID_1_"/></clipPath><path class="st0" d="M306,629.5c128.8,0,233.5-104.7,233.5-233.5S434.8,162.5,306,162.5S72.5,267.2,72.5,396    S177.2,629.5,306,629.5L306,629.5z"/></g><polygon class="st1" points="421.4,271 241.9,450.5 174.9,383.5 122,436.4 241.9,556.2 257.3,540.8 257.4,540.8 474.3,323.9    421.4,271  "/></g></svg>
                    </td>
                    <td></td>
                    <td></td>
                    <td></td>
                  </tr>
                  <tr class="border-bottom">
                    <th scope="row">Destroy</th>
                    <td>
                      <svg class="circle-check" id="Layer_1" style="enable-background:new 0 0 612 792;" version="1.1" viewBox="0 0 612 792" xml:space="preserve" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink"><style type="text/css">
                        .st0{clip-path:url(#SVGID_2_);fill:none;stroke:#41AD49;stroke-width:32;}
                        .st1{fill:#41AD49;}
                      </style><g><g><defs><rect height="512" id="SVGID_1_" width="512" x="50" y="140"/></defs><clipPath id="SVGID_2_"><use style="overflow:visible;" xlink:href="#SVGID_1_"/></clipPath><path class="st0" d="M306,629.5c128.8,0,233.5-104.7,233.5-233.5S434.8,162.5,306,162.5S72.5,267.2,72.5,396    S177.2,629.5,306,629.5L306,629.5z"/></g><polygon class="st1" points="421.4,271 241.9,450.5 174.9,383.5 122,436.4 241.9,556.2 257.3,540.8 257.4,540.8 474.3,323.9    421.4,271  "/></g></svg>
                    </td>
                    <td></td>
                    <td></td>
                    <td></td>
                    <td></td>
                  </tr>
                  <tr class="border-bottom">
                    <th scope="row">Ship</th>
                    <td>
                      <svg class="circle-check" id="Layer_1" style="enable-background:new 0 0 612 792;" version="1.1" viewBox="0 0 612 792" xml:space="preserve" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink"><style type="text/css">
                        .st0{clip-path:url(#SVGID_2_);fill:none;stroke:#41AD49;stroke-width:32;}
                        .st1{fill:#41AD49;}
                      </style><g><g><defs><rect height="512" id="SVGID_1_" width="512" x="50" y="140"/></defs><clipPath id="SVGID_2_"><use style="overflow:visible;" xlink:href="#SVGID_1_"/></clipPath><path class="st0" d="M306,629.5c128.8,0,233.5-104.7,233.5-233.5S434.8,162.5,306,162.5S72.5,267.2,72.5,396    S177.2,629.5,306,629.5L306,629.5z"/></g><polygon class="st1" points="421.4,271 241.9,450.5 174.9,383.5 122,436.4 241.9,556.2 257.3,540.8 257.4,540.8 474.3,323.9    421.4,271  "/></g></svg>
                    </td>
                    <td>
                      <svg class="circle-check" id="Layer_1" style="enable-background:new 0 0 612 792;" version="1.1" viewBox="0 0 612 792" xml:space="preserve" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink"><style type="text/css">
                        .st0{clip-path:url(#SVGID_2_);fill:none;stroke:#41AD49;stroke-width:32;}
                        .st1{fill:#41AD49;}
                      </style><g><g><defs><rect height="512" id="SVGID_1_" width="512" x="50" y="140"/></defs><clipPath id="SVGID_2_"><use style="overflow:visible;" xlink:href="#SVGID_1_"/></clipPath><path class="st0" d="M306,629.5c128.8,0,233.5-104.7,233.5-233.5S434.8,162.5,306,162.5S72.5,267.2,72.5,396    S177.2,629.5,306,629.5L306,629.5z"/></g><polygon class="st1" points="421.4,271 241.9,450.5 174.9,383.5 122,436.4 241.9,556.2 257.3,540.8 257.4,540.8 474.3,323.9    421.4,271  "/></g></svg>
                    </td>
                    <td></td>
                    <td></td>
                    <td></td>
                  </tr>
                  <tr>
                    <th scope="row">Complete</th>
                    <td>
                      <svg class="circle-check" id="Layer_1" style="enable-background:new 0 0 612 792;" version="1.1" viewBox="0 0 612 792" xml:space="preserve" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink"><style type="text/css">
                        .st0{clip-path:url(#SVGID_2_);fill:none;stroke:#41AD49;stroke-width:32;}
                        .st1{fill:#41AD49;}
                      </style><g><g><defs><rect height="512" id="SVGID_1_" width="512" x="50" y="140"/></defs><clipPath id="SVGID_2_"><use style="overflow:visible;" xlink:href="#SVGID_1_"/></clipPath><path class="st0" d="M306,629.5c128.8,0,233.5-104.7,233.5-233.5S434.8,162.5,306,162.5S72.5,267.2,72.5,396    S177.2,629.5,306,629.5L306,629.5z"/></g><polygon class="st1" points="421.4,271 241.9,450.5 174.9,383.5 122,436.4 241.9,556.2 257.3,540.8 257.4,540.8 474.3,323.9    421.4,271  "/></g></svg>
                    </td>
                    <td>
                      <svg class="circle-check" id="Layer_1" style="enable-background:new 0 0 612 792;" version="1.1" viewBox="0 0 612 792" xml:space="preserve" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink"><style type="text/css">
                        .st0{clip-path:url(#SVGID_2_);fill:none;stroke:#41AD49;stroke-width:32;}
                        .st1{fill:#41AD49;}
                      </style><g><g><defs><rect height="512" id="SVGID_1_" width="512" x="50" y="140"/></defs><clipPath id="SVGID_2_"><use style="overflow:visible;" xlink:href="#SVGID_1_"/></clipPath><path class="st0" d="M306,629.5c128.8,0,233.5-104.7,233.5-233.5S434.8,162.5,306,162.5S72.5,267.2,72.5,396    S177.2,629.5,306,629.5L306,629.5z"/></g><polygon class="st1" points="421.4,271 241.9,450.5 174.9,383.5 122,436.4 241.9,556.2 257.3,540.8 257.4,540.8 474.3,323.9    421.4,271  "/></g></svg>
                    </td>
                    <td></td>
                    <td></td>
                    <td></td>
                  </tr>
                </tbody>
              </table>    
            </div>
          </div>
        </div>





      </div>
    </div>
  </div>  
</div>



Hi
<form>
  <div class="custom-control custom-checkbox">
    <input type="checkbox" class="custom-control-input" id="customCheck1" checked=true>
  </div>
</form>

Bye
    """
  end

  @impl true
  def handle_event("validate", _, socket) do
    {:noreply, socket}
  end

  def handle_event("show_info", %{"name" => name}, socket) do
    {:noreply, push_redirect(socket, to: ash_dashboard_path(socket, :resource, [], name))}
  end

  def handle_event("new", _, socket) do
    {:noreply, push_redirect(socket, to: ash_dashboard_path(socket, :resources_new))}
  end

  def handle_event("import", _, socket) do
    {:noreply, push_redirect(socket, to: ash_dashboard_path(socket, :resources_import))}
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
