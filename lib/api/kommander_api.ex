defmodule Flamelex.API.Kommander do
  @moduledoc """
  This API module is the interface for all functionality relating to the
  KommandBuffer.

  Note that it is called `Kommander` in order to distinguish it from the
  actual KommandBuffer module - initially, this module was API.KommandBuffer,
  but there was some confusion due to a double-use, especially when you
  start to use module alias'... it's just better this way.
  """


  @doc """
  Make the KommandBuffer visible.
  """
  def show do
    Flamelex.Fluxus.action({Flamelex.Fluxus.Reducers.Kommander, :show})
  end


  @doc """
  Same as show/0
  """
  def open do
    show()
  end


  @doc """
  Make the KommandBuffer not-visible, and put us in :normal mode.
  """
  def hide do
    Flamelex.Fluxus.action({Flamelex.Fluxus.Reducers.Kommander, :hide})
  end


  @doc """
  Resets the text field to an empty string.
  """
  def clear do
    Flamelex.Fluxus.action({Flamelex.Fluxus.Reducers.Kommander, :clear})
  end


  @doc """
  Modify the KommandBuffer.
  """
  def modify(modification) do
    Flamelex.Fluxus.action({Flamelex.Fluxus.Reducers.Kommander, {:modify_kommander, modification}})
  end

  @doc """
  The difference between this function and hide is that hide simply makes
  the API.CommandBuffer invisible in the GUI, but usually when we want it to go
  away we also want to forget all the state in the KommandBuffer - like
  when you mash escape to go back to :edit mode
  """
  def reset do
    Flamelex.Fluxus.action([
      clear(),
      hide()
    ])
  end


  @doc """
  Execute the command in the API.CommandBuffer
  """
  def execute do
    Flamelex.Fluxus.action({Flamelex.Fluxus.Reducers.Kommander, :execute})
  end
end
