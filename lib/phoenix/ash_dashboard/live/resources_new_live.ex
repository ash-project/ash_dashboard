defmodule AshDashboard.ResourcesNewLive do
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
      New Resource
      <div class="form-row">
        <div class="form-group col-sm-11">
          <%= live_redirect("Back", to: ash_dashboard_path(@socket, :resources), class: "menu-item") %>
        </div>
        <div class="form-group col-sm-1">
          <button type="submit" class="btn btn-primary">Submit</button>
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
