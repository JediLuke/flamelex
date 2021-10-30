defmodule Flamelex.GUI.TopLevelSupervisor do
  @moduledoc false
  use Supervisor
  require Logger

  def start_link(params) do
    Supervisor.start_link(__MODULE__, params, name: __MODULE__)
  end

  def init(_params) do
    Logger.debug "#{__MODULE__} initializing..."

    children = [
      {Scenic, [default_viewport_config()]},
      Flamelex.GUI.Controller,
      Flamelex.GUI.VimSupervisor
    ]

    Supervisor.init(children, strategy: :one_for_all)
  end



  defp default_viewport_config do
    Flamelex.GUI.ScenicInitialize.viewport_config()
  end
end
