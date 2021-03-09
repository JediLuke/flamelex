defmodule Flamelex.Buffer do
  @moduledoc """
  Flamelex.Buffer exposes the Buffer functionality.

  Users should never call this directly! Users go through APIs, which fire
  actions - and inside the reducers, that's where these functions will
  get called.
  """


  def open!(%{type: buffer_module} = params) when is_atom(buffer_module) do
    Flamelex.Buffer.SeniorSupervisor.open_buffer!({buffer_module, params})
  end

  # def modify()
end
