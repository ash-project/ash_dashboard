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
      single resource 1
      @resource
      <%= Ash.name(@resource) %>
      <%= live_redirect("Back", to: ash_dashboard_path(@socket, :resources), class: "menu-item") %>



      <%= f = form_for @resource, "#", [phx_change: :validate, phx_submit: :save, class: "resource"] %>

      <section class="info">
        <h5>Info</h5>
        <div class="group">
          <%= label f, :name %>
          <input value="<%= @resource.name() %>">
        </div>

        <div class="group">
          <%= label f, :type %>
          <input value="<%= @resource.type() %>">
        </div>

        <div class="group">
          <%= label f, :max_page_size %>
          <input value="<%= @resource.max_page_size() %>" type="number">
        </div>

        <div class="group">
          <%= label f, :default_page_size %>
          <input value="<%= @resource.default_page_size() %>" type="number">
        </div>

        <div class="group">
          <%= label f, :primary_key %>
            <input value="<%= List.first(@resource.primary_key()) |> Atom.to_string() %>">
          </div>
      </section>

      <section class="attributes">
        <h5>Attributes</h5>
        <%= for attribute <- @resource.attributes do %>
          <div class="group">
            <%= label f, attribute.name %>
            <input>
          </div>
        <% end %>
      </section>

      <section class="actions">
        <h5>Actions</h5>
        <%= for action <- @resource.actions do %>
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

    """
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


# <%= for resource <- @resources do %>
# <%= Ash.name(resource) %>

# <%= f = form_for resource, "#", [phx_change: :validate, phx_submit: :save, class: "form-inline"] %>

#   <%= label f, :name %>
#   <%= text_input f, :name %>

#   <%= label f, :type %>
#   <%= text_input f, :type %>

#   <br>

#   <%= label f, :max_page_size %>
#   <%= number_input f, :max_page_size %>

#   <%= label f, :default_page_size %>
#   <%= number_input f, :default_page_size %>

#   <%= label f, :primary_key %>
#   <%= checkbox f, :primary_key %>

#   <%= submit "Save", phx_disable_with: "Saving..." %>
# </form>
# <br>
# <br>
# <% end %>


# @impl true
# def handle_event("validate", _, socket) do
#   IO.inspect('validate event')  
#   {:noreply, socket}
# end

# @impl true
# def handle_event("save", _, _csrf_token, socket) do
#   IO.inspect('validate event')  
#   {:noreply, socket}
# end
