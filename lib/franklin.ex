defmodule Franklin do

  # simple `use Franklin` to
  defmacro __using__(_) do
    quote do
      import Franklin.CLI
      alias Franklin.CLI, as: Fnk
    end
  end

  def help do
    IO.puts "You probably want to `use Franklin`..."
    Franklin.CLI.help()
  end
end
