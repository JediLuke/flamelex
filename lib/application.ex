defmodule Franklin.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      Franklin.Commander,
      Franklin.PubSub,
      Franklin.Buffer.TopLevelSupervisor,
      {Scenic, viewports: [GUI.Initialize.viewport_config()]}
    ]

    opts = [strategy: :one_for_one, name: Franklin.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
