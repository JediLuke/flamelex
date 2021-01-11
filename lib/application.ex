defmodule Flamelex.Application do
  @moduledoc false
  use Application


  def start(_type, _args) do

    IO.puts "#{__MODULE__} initializing..."

    start_gui? = true

    children =
        if start_gui? do
          boot_gui_process_tree() ++ boot_regular_applications()
        else
          boot_regular_applications()
        end

    opts = [strategy: :one_for_one, name: Flamelex.Trismegistus]
    Supervisor.start_link(children, opts)
  end





  defp boot_gui_process_tree do
    [
      Flamelex.GUI.TopLevelSupervisor
    ]
  end

  defp boot_regular_applications do
    [
      Flamelex.Fluxus.TopLevelSupervisor,
      Flamelex.Buffer.TopLevelSupervisor,
      # Flamelex.Agent.TopLevelSupervisor, #TODO this is just commented out to stop spamming the log with reminders atm
    ]
  end
end
