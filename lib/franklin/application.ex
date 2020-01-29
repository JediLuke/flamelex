defmodule Franklin.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children =
      [] # start with an empty list
      |> Enum.concat(GUI.startup_process_childspec_list())

    opts = [strategy: :one_for_one, name: Franklin.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
