defmodule Flamelex.API.GUI.TopLevelSupervisor do
  @moduledoc false
  use Supervisor

  def start_link(params), do: Supervisor.start_link(__MODULE__, params, name: __MODULE__)

  def init(_params) do
    IO.puts "#{__MODULE__} initializing..."

    # Flamelex.API.GUI.Initialize.load_custom_fonts_into_global_cache()

    children = [
      {Scenic, viewports: [Flamelex.API.GUI.Initialize.viewport_config()]},
      Flamelex.API.GUI.Controller
    ]

    Supervisor.init(children, strategy: :one_for_all)
  end
end
