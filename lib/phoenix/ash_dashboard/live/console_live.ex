defmodule AshDashboard.ConsoleLive do
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
    api =
      case socket.assigns.apis do
        [api] -> api
        _ -> raise "we don't support multiple APIs now"
      end

    resources = Ash.resources(api)
    assign(socket, resources: resources)
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
      <h1>Ash Console</h1>

      <%= for resource <- @resources do %>
        <%= Ash.name(resource) %>
      <% end %>

      <h3>Data Access</h3>
      <section class="layer data-access">
        <section class="option">
          <div>Ash Function</div>
          <textarea id="ash"></textarea>
        </section>
      </section>
  
      <h3>SQL</h3>
      <section class="layer sql">
        <section class="option" phx-hook="HighlightCode" phx-ignore=true>
          <div>Statement</div>
          <pre>
            <code class="language-sql">
              SELECT
                e0."school_id",
                e0."active",
                e0."updated_at",
                e0."created_at",
                e0."id",
                e0."role",
                e0."image_url",
                e0."email",
                e0."last_name",
                e0."first_name"
              FROM
                "educators" AS e0
            </code>
          </pre>
          <textarea id="query"></textarea>
        </section>
        <section class="option">
          <div>Explanation</div>
          <textarea id="explained"></textarea>
        </section>
      </section>
  
      <script type="text/javascript">
  
        var ashResult = "Blueprint.Api.read(Blueprint.Educator)"
        var ashTextArea = document.getElementById("ash")
        var ash = CodeMirror.fromTextArea(ashTextArea, {
          lineNumbers: true,
          mode: "text/x-pgsql",
        });
        ash.getDoc().setValue(ashResult);
  
      </script>    
  
  
      <script type="text/javascript">
  
        var queryResult = `SELECT
    e0."school_id",
    e0."active",
    e0."updated_at",
    e0."created_at",
    e0."id",
    e0."role",
    e0."image_url",
    e0."email",
    e0."last_name",
    e0."first_name"
  FROM
    "educators" AS e0
  `
        var queryTextArea = document.getElementById("query")
        var query = CodeMirror.fromTextArea(queryTextArea, {
          lineNumbers: true,
          mode: "text/x-pgsql",
        });
        query.getDoc().setValue(queryResult);
  
      </script>     
  
      <script type="text/javascript">
        var explainedResult = `[
    [
      {
        "Execution Time": 0.105,
        "Plan": {
          "Actual Loops": 1,
          "Actual Rows": 95,
          "Actual Startup Time": 0.017,
          "Actual Total Time": 0.052,
          "Alias": "e0",
          "Node Type": "Seq Scan",
          "Parallel Aware": false,
          "Plan Rows": 95,
          "Plan Width": 108,
          "Relation Name": "educators",
          "Startup Cost": 0.0,
          "Total Cost": 2.95
        },
        "Planning Time": 0.09,
        "Triggers": []
      }
    ]
  ]
  `
        var explainedTextArea = document.getElementById("explained")
        var explained = CodeMirror.fromTextArea(explainedTextArea, {
          lineNumbers: true,
          mode: "text/x-pgsql",
        });
        explained.getDoc().setValue(explainedResult);
  
      </script>

    """
  end
end
