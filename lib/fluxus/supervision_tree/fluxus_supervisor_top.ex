defmodule Flamelex.Fluxus.TopLevelSupervisor do
  @moduledoc false
  use Supervisor
  require Logger

  def start_link(params) do
    Supervisor.start_link(__MODULE__, params, name: __MODULE__)
  end

  def init(_params) do
    Logger.debug "#{__MODULE__} initializing..."

    children = [
      {Registry, keys: :duplicate, name: Fluxus.PubSub}, # https://hexdocs.pm/elixir/1.12/Registry.html#module-using-as-a-dispatcher
      Flamelex.Fluxus.RadixStore,
      Flamelex.Fluxus.ActionListener,
      Flamelex.Fluxus.InputListener
    ]

    Supervisor.init(children, strategy: :one_for_all) #TODO make this :rest_for_one?
  end
end
