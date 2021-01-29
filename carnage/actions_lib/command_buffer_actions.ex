defmodule Flamelex.Fluxus.Actions.CommandBufferActions do
  @moduledoc """
  This module provides some basic functions which return tuples, representing
  actions inside flamelex.

  #TODO this is what we want to figure out...
  By default, it assumed you want to apply the action to the active buffer.
  """

  def show do
    {:action, {:command_buffer, :show}}
  end

  def hide do
    {:action, {:command_buffer, :hide}}
  end

  def clear do
    {:action, {:command_buffer, :clear}}
  end

  def input(t) do
    {:action, {:command_buffer, :input, t}}
  end
end
