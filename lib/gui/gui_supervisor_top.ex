defmodule Flamelex.GUI.TopLevelSupervisor do
  @moduledoc false
  use Supervisor

  def start_link(params), do: Supervisor.start_link(__MODULE__, params, name: __MODULE__)

  def init(_params) do
    IO.puts "#{__MODULE__} initializing..."

    children = [
      {Scenic, viewports: [GUI.Initialize.viewport_config()]},
      Flamelex.GUI.Controller
    ]

    Supervisor.init(children, strategy: :one_for_all)
  end
end
