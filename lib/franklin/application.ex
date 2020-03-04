defmodule Franklin.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      Franklin.Commander,
      Franklin.BufferSupervisor,
      # Franklin.PubSub,
      GUI.Initialize.scenic_childspec
    ]

    opts = [strategy: :one_for_one, name: Franklin.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
