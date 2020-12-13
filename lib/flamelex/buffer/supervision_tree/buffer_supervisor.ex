defmodule Flamelex.Buffer.Supervisor do
  use DynamicSupervisor


  def start_link(args) do
    DynamicSupervisor.start_link(__MODULE__, args, name: __MODULE__)
  end


  def init(_args) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
