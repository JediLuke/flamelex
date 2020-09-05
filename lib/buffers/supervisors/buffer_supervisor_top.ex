defmodule Franklin.Buffer.TopLevelSupervisor do
  @moduledoc """
  This Supervisor monitors the Buffer.Manager and the Buffer.DynamicSupervisor
  """
  use Supervisor
  require Logger


  def start_link(params) do
    Supervisor.start_link(__MODULE__, params, name: __MODULE__)
  end


  def init(_params) do
    Logger.info("#{__MODULE__} initializing...")

    children = [
      Franklin.Buffer.Supervisor,
      Flamelex.Buffer.Command
    ]

    Supervisor.init(children, strategy: :one_for_all)
  end
end
