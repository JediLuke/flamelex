defmodule Flamelex do
  @moduledoc """
  The main interface to the Flamelex application.
  """
  use Flamelex.ProjectAliases

  @valid_modes [:command, :insert, :visual_select]

  @doc """
  `Know Thyself`

  Use this function to recompile, reload and restart the `Flamelex` application.

  https://www.youtube.com/watch?v=kl0rqoRbzzU

  Flamelex is an interactive thinking-space. It is intended to be edited
  on by the user, and incorporate changes to it's own codebase. It is a
  more refined version of the original Lisp machine. When you make
  changes in your Flamelex code/environment (try to start thinking of those
  two as the same thing), sometimes you need to (safely!) shut-down the
  application & restart it, without losing any state. That is what this
  function is for. Except the keeping state part, that doesn't work yet!
  """
  def temet_nosce do
    IO.puts "\n#{__MODULE__} stopping..."
    Application.stop(:flamelex)

    IO.puts "\n#{__MODULE__} recompiling..."
    IEx.Helpers.recompile

    IO.puts "\n#{__MODULE__} starting...\n"
    Application.start(:flamelex)
  end

  def switch_mode(m) when m in @valid_modes do
    GenServer.cast(Flamelex.FluxusRadix, {:action, {:switch_mode, m}})
  end


  def set_log_level(l) do
    raise "How do I set the log level??"
  end

  def help do
    raise "no help to be found :("
  end
end
