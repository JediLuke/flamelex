defmodule Flamelex.Memex.Env.JediLuke do
  @moduledoc """
  My primary environment.
  """
  use Flamelex.Memex.Environment

  def timezone do
    Memex.Episteme.TimeZones.texas()
  end

  def todo_list do
    JediLuke.TODOlist.all()
  end

  def reminders do
    []
  end

  def journal do
    JediLuke.Journal
  end
end
