defmodule Flamelex.Fluxus.Actions.CoreActions do
  @moduledoc """
  This module provides some basic functions which return tuples, representing
  actions inside flamelex.
  By default, it assumed you want to apply the action to the active buffer.
  """

  def open_buffer() do
    {:action, :open_buffer}
  end

  def switch_mode(m)  when is_atom(m) do
    {:action, {:switch_mode, m}}
  end
end
