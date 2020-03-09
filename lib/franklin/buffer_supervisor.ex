defmodule Franklin.BufferSupervisor do
  # Automatically defines child_spec/1
  use DynamicSupervisor

  def start_link(init_arg) do
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def note(contents) do
    DynamicSupervisor.start_child(__MODULE__, {Franklin.Buffer.Note, contents})
  end

  def list(:notes) do
    DynamicSupervisor.start_child(__MODULE__, {Franklin.Buffer.List, :notes})
  end
end
