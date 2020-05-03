Application.put_env(:ash_dashboard, AshDashboardTest.Endpoint,
  url: [host: "localhost", port: 4000],
  secret_key_base: "Hu4qQN3iKzTV4fJxhorPQlA/osH9fAMtbtjVS58PFgfw3ja5Z18Q/WSNR9wP4OfW",
  live_view: [signing_salt: "hMegieSe"],
  render_errors: [view: AshDashboardTest.ErrorView],
  check_origin: false,
  pubsub: [name: AshDashboardTest.PubSub, adapter: Phoenix.PubSub.PG2]
)

defmodule AshDashboardTest.ErrorView do
  use Phoenix.View, root: "test/templates"

  def template_not_found(template, _assigns) do
    Phoenix.Controller.status_message_from_template(template)
  end
end

defmodule AshDashboardTest.Telemetry do
  import Telemetry.Metrics

  def metrics do
    [
      counter("phx.b.c"),
      counter("phx.b.d"),
      counter("ecto.f.g"),
      counter("my_app.h.i")
    ]
  end
end

defmodule AshDashboardTest.Router do
  use Phoenix.Router
  import AshDashboard.Router

  pipeline :browser do
    plug :fetch_session
  end

  scope "/", ThisWontBeUsed, as: :this_wont_be_used do
    pipe_through :browser
    ash_dashboard("/dashboard", metrics: AshDashboardTest.Telemetry)
  end
end

defmodule AshDashboardTest.Endpoint do
  use Phoenix.Endpoint, otp_app: :ash_dashboard

  plug AshDashboard.RequestLogger,
    param_key: "request_logger_param_key",
    cookie_key: "request_logger_cookie_key"

  plug Plug.Session,
    store: :cookie,
    key: "_live_view_key",
    signing_salt: "/VEDsdfsffMnp5"

  plug AshDashboardTest.Router
end

Application.ensure_all_started(:os_mon)
AshDashboardTest.Endpoint.start_link()
ExUnit.start()
