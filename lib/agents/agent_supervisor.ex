defmodule Franklin.Agent.Supervisor do
  use DynamicSupervisor # Automatically defines child_spec/1

  def start_link(args), do:
    DynamicSupervisor.start_link(__MODULE__, args, name: __MODULE__)

  def init(_args), do: DynamicSupervisor.init(strategy: :one_for_one)

  def note(contents), do: start_new_buffer_process({Franklin.Buffer.Note, contents})

  def list(:notes),   do: start_new_buffer_process({Franklin.Buffer.List, :notes})


  # private functions


  defp start_new_buffer_process(args), do:
    DynamicSupervisor.start_child(__MODULE__, args)

end
