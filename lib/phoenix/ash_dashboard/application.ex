defmodule AshDashboard.Application do
  @moduledoc false
  use Application

  def start(_, _) do
    children = [
      {DynamicSupervisor, name: AshDashboard.DynamicSupervisor, strategy: :one_for_one}
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
