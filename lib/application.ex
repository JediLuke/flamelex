defmodule Flamelex.Application do
  @moduledoc false
  use Application
  require Logger


  def start(_type, _args) do

    Logger.debug "#{__MODULE__} initializing..."

    children = [
      #Note: Fluxus has to come before gui cause gui calls RadixStore to get it's init state
      Flamelex.Fluxus.TopLevelSupervisor,
      Flamelex.Buffer.TopLevelSupervisor,
      Flamelex.GUI.TopLevelSupervisor
    ]

    opts = [strategy: :one_for_one, name: Flamelex.Trismegistus]
    Supervisor.start_link(children, opts)
  end

end
