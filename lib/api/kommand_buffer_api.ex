defmodule Flamelex.API.KommandBuffer do
  @moduledoc """
  This API module is the interface for all functionality relating to the
  KommandBuffer.
  """


  @doc """
  Make the KommandBuffer visible, and put us in :command mode.
  """
  def show do
    Flamelex.Fluxus.fire_action({KommandBuffer, :show})
  end


  @doc """
  Make the KommandBuffer not-visible, and put us in :normal mode.
  """
  def hide do
    Flamelex.Fluxus.fire_action({KommandBuffer, :hide})
  end


  @doc """
  Resets the text field to an empty string.
  """
  def clear do
    Flamelex.Fluxus.fire_action({KommandBuffer, :clear})
  end


  @doc """
  The difference between this function and hide is that hide simply makes
  the API.CommandBuffer invisible in the GUI, but usually when we want it to go
  away we also want to forget all the state in the KommandBuffer - like
  when you mash escape to go back to :edit mode
  """
  def deactivate do
    Flamelex.Fluxus.fire_actions([
      clear(),
      hide()
    ])
  end


  @doc """
  Send input to the API.CommandBuffer
  """
  def input(x) do
    Flamelex.Fluxus.fire_action({KommandBuffer, {:input, x}})
  end


  @doc """
  Execute the command in the API.CommandBuffer
  """
  def execute do
    Flamelex.Fluxus.fire_action({KommandBuffer, :execute})
  end
end
