defmodule Flamelex.Buffer.Supervisor do
  use DynamicSupervisor


  def start_link(args) do
    DynamicSupervisor.start_link(__MODULE__, args, name: __MODULE__)
  end


  def init(_args) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  # def start_buffer_process(buffer_type, opts) do
  #   DynamicSupervisor.start_child(__MODULE__, {buffer_type, opts})
  # end
end
