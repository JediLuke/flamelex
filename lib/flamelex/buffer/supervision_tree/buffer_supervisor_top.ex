defmodule Flamelex.Buffer.TopLevelSupervisor do
  @moduledoc """
  This Supervisor monitors the Buffer.Manager and the Buffer.DynamicSupervisor
  """
  use Supervisor
  require Logger


  def start_link(params) do
    Supervisor.start_link(__MODULE__, params, name: __MODULE__)
  end


  def init(_params) do
    IO.puts "#{__MODULE__} initializing..."

    children = [
      # {Registry, keys: :unique, name: Flamelex.Buffer.ProcessRegistry},
      #TODO put all these tasks supervisors, under 1 supervisors? Or, marry
      # them up to one higher-up supervisor per sub-area??
      {Task.Supervisor, name: Flamelex.Buffer.Reducer.TaskSupervisor},
      {Task.Supervisor, name: KommandBuffer.Reducer},
      Flamelex.Buffer.SeniorSupervisor,
      Flamelex.BufferManager,
      {Flamelex.Buffer.KommandBuffer, %{rego_tag: {:buffer, KommandBuffer}}},
      # {Registry, keys: :unique, name: BufferRegistry},
    ]

    Supervisor.init(children, strategy: :one_for_all)
  end
end
