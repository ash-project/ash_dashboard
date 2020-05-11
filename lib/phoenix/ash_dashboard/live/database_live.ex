defmodule AshDashboard.DatabaseLive do
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
      Import Your Resource
      <%= for s <- schema do %>
        <div class="card mb-2">
          <div class="card-header">
            <%= s[:name] %> - <%= s[:type] %>: <%= length(s[:columns]) %> columns
          </div>
          <div class="card-body">
            <%= for c <- s[:columns] do %>
              <span class="badge badge-light"><%= c["name"] %></span>
            <% end %>
          </div>
        </div>
      <% end %>
  
      <div class="form-row">
        <div class="form-group col-sm-11">
          <%= live_redirect("Back", to: ash_dashboard_path(@socket, :resources), class: "menu-item") %>
        </div>
        <div class="form-group col-sm-1">
          <button type="submit" class="btn btn-primary">Import All</button>
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

  def schema do
    tables
    |> Enum.map(fn table ->
      %{
        name: table["table_name"],
        type: table["table_type"],
        columns: Enum.filter(columns, fn c -> c["table_name"] == table["table_name"] end)
      }
    end)
  end

  def tables_query do
    """
    SELECT table_name, table_type
    from information_schema.tables
    WHERE table_schema='public'
    AND NOT table_name='schema_migrations'
    AND NOT table_name='ar_internal_metadata'
    """
  end

  def tables do
    result_to_maps(Ecto.Adapters.SQL.query!(Blueprint.Repo, tables_query))
  end

  def columns do
    result_to_maps(Ecto.Adapters.SQL.query!(Blueprint.Repo, columns_query))
  end

  def columns_query do
    """
    SELECT
      columns.column_name as name,
      columns.column_default as default,
      columns.is_nullable as allow_nil,
      columns.udt_name as type,
      columns.table_name,
      constraints.constraint_type as constraint
    FROM (
      select column_name, column_default, is_nullable, udt_name, table_name
      from information_schema.columns
      WHERE table_schema='public'
      AND NOT table_name='schema_migrations'
      AND NOT table_name='ar_internal_metadata'
    ) columns
    LEFT JOIN
      (SELECT c.column_name, c.table_name, t.constraint_type
      FROM information_schema.key_column_usage AS c
      LEFT JOIN information_schema.table_constraints AS t
      ON t.constraint_name = c.constraint_name
      WHERE t.table_name = c.table_name
      AND c.table_schema='public'
      AND NOT c.table_name='schema_migrations'
      AND NOT c.table_name='ar_internal_metadata'
    ) constraints
    ON columns.table_name = constraints.table_name
    AND columns.column_name = constraints.column_name
    """
  end

  def result_to_maps(%Postgrex.Result{columns: _, rows: nil}), do: []

  def result_to_maps(%Postgrex.Result{columns: col_nms, rows: rows}) do
    Enum.map(rows, fn(row) -> row_to_map(col_nms, row) end)
  end

  def row_to_map(col_nms, vals) do
    Stream.zip(col_nms, vals)
    |> Enum.into(Map.new(), &(&1))
  end
end
