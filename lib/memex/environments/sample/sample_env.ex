defmodule Flamelex.Memex.Env.SampleEnv do
  @moduledoc """
  A sample Memex environment.
  """
  use Flamelex.Memex.Environment

  def timezone, do: "Etc/UTC"

  def todo_list, do: [
    "mow the lawn",
    "read a philosophy book",
    "call grandma"
  ]

  def reminders, do: []

end
