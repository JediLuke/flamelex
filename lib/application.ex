defmodule Flamelex.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do

    IO.puts "#{__MODULE__} initializing..."

    children = [
      Flamelex.GUI.TopLevelSupervisor,
      Flamelex.OmegaMaster,
      Flamelex.Buffer.TopLevelSupervisor,
      # Flamelex.Agent.TopLevelSupervisor, #TODO this is just commented out to stop spamming the log with reminders atm
    ]

    opts = [strategy: :one_for_one, name: Flamelex.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
