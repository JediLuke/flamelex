defmodule Flamelex.API.Kommander do
  @moduledoc """
  This API module is the interface for all functionality relating to the
  KommandBuffer.

  Note that it is called `Kommander` in order to distinguish it from the
  actual KommandBuffer module - initially, this module was API.KommandBuffer,
  but there was some confusion due to a double-use, especially when you
  start to use module alias'... it's just better this way.
  """
  require Logger


  @doc """
  Make the KommandBuffer visible, and put us in :kommand mode.
  """
  def show do

    Flamelex.Fluxus.fire_action({KommandBuffer, :show})
  end


  @doc """
  Same as show/0 - open up (or, make visible) the KommandBuffer, and put
  us in :kommand mode.
  """
  def open do
    Logger.debug "opening KommandBuffer..."
    show()
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
  def reset do
    Flamelex.Fluxus.fire_actions([
      clear(),
      hide()
    ])
  end


  @doc """
  Execute the command in the API.CommandBuffer
  """
  def execute do
    Flamelex.Fluxus.fire_action({KommandBuffer, :execute})
  end
end
