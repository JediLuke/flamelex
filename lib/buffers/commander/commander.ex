defmodule Flamelex.Commander do
  @moduledoc """
  This module contains functions used to interface with the command
  buffer (Flamelex.Buffer.Command).
  """

  @commander Flamelex.Buffer.Command

  def activate,              do: cast_cmder(:activate)
  def deactivate,            do: cast_cmder(:deactivate)
  def enter_character(char), do: cast_cmder({:enter_char, char})
  def backspace,             do: cast_cmder(:backspace)
  def reset_text_field,      do: cast_cmder(:reset_text_field)
  def execute_contents,      do: cast_cmder(:execute_contents)

  defp cast_cmder(action), do: GenServer.cast(@commander, action)

end
