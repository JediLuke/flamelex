defmodule Flamelex.GUI.TopLevelSupervisor do
  @moduledoc false
  use Supervisor

  def start_link(params), do: Supervisor.start_link(__MODULE__, params, name: __MODULE__)

  def init(_params) do
    IO.puts "#{__MODULE__} initializing..."

    # Flamelex.Flamelex.GUI.Initialize.load_custom_fonts_into_global_cache()

    children = [
      {Scenic, viewports: [Flamelex.GUI.Initialize.viewport_config()]},
      Flamelex.GUI.Controller
    ]

    Supervisor.init(children, strategy: :one_for_all)
  end
end
