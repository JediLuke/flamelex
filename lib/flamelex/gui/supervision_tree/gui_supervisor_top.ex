defmodule Flamelex.GUI.TopLevelSupervisor do
  @moduledoc false
  use Supervisor

  def start_link(params) do
    Supervisor.start_link(__MODULE__, params, name: __MODULE__)
  end

  def init(_params) do
    IO.puts "#{__MODULE__} initializing..."

    children = [
      {Scenic, viewports: [default_viewport_config()]},
      Flamelex.GUI.Controller #TODO which should boot first, Scenic, or GUiController?
    ]

    Supervisor.init(children, strategy: :one_for_all)
  end



  defp default_viewport_config do
    Flamelex.GUI.ScenicInitializationHelper.viewport_config()
  end
end
