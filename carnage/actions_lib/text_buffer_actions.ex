defmodule Flamelex.Fluxus.Actions.TextBufferActions do
  @moduledoc """
  This module provides some basic functions which return tuples, representing
  actions inside flamelex.
  By default, it assumed you want to apply the action to the active buffer.
  """

  #TODO for now, just assume 1 cursor...

  def move_cursor(buf, [to: destination]) do
    {:action, {buf, :move_cursor, %{to: destination}}}
  end

  def move_cursor(buf, direction, amount, unit) do
    {:action, {buf, :move_cursor, %{direction: direction, amount: amount, unit: unit}}}
  end

  # def modify
end
