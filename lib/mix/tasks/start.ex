defmodule Mix.Tasks.Start do
  @moduledoc """
  Call this task by typing:

  ```
  mix start
  ```

  Note that for Mix tasks, the module name is important -
  don't rename it to have Flamelex at the front ;)
  """
  use Mix.Task

  def run(_) do
    start_flamelex()
  end

  # @shortdoc "Simply calls the Hello.say/0 function."
  def start_flamelex do
    Mix.Task.run("app.start")
    IO.puts "Here we start Flamelex!"
  end
end
