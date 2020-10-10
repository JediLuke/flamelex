defmodule Flamelex.Application do
  @moduledoc ~S(`Franklin` is a Memex & computation tool written in Elixir.)

  use Application

  def start(_type, _args) do

    IO.puts "#{__MODULE__} initializing..."

    children = [
      Flamelex.GUI.TopLevelSupervisor,
      Flamelex.OmegaMaster,
      Flamelex.Buffer.TopLevelSupervisor,
      # Franklin.Agent.TopLevelSupervisor, #TODO this is just commented out to stop spamming the log with reminders atm
    ]

    opts = [strategy: :one_for_one, name: Franklin.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
