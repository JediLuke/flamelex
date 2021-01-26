defmodule Flamelex.API.DevTools do
  @moduledoc """
  When we need to fire actions/whatever during the dev process.
  """
  use Flamelex.ProjectAliases


  def test do
    Flamelex.Fluxus.fire_action( CoreActions.open_buffer() )
  end
end
