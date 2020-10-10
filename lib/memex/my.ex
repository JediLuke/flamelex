defmodule Flamelex.Memex.My do
  @moduledoc """
  This is the API for accessing data from the loaded environment.

  e.g.

  Memex.My.current_timezone()
  "AEST"

  """
  use Flamelex.CommonDeclarations

  @doc """
  Return the currently loaded Memex Environment.

  This atom is the module name, which provides the entry point for the
  environment (it uses Flamelex.Memex.Environment, and thus must implement
  that behaviour)
  """
  def memex_env, do: Memex.default_env()

  def current_time do
    memex_env().timezone() |> DateTime.now!()
  end

  def todo_list do
    memex_env().todo_list()
  end
end
