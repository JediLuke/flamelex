defmodule Flamelex do
  @moduledoc """
  The main interface to the Flamelex application.

  Note that in order to have these functions automatically
  available in the MenuBar, they need to be in a module called
  `Flamelex.API` - but this is less desirable for users calling
  the functions directly in the command line (where I want to
  be able to say `Flamelex.temet_nosce` rather than the more
  cumbersome `Flamelex.API.temet_nosce`) - the workaround is to
  delegate functions here to Flamelex.API
  """

  #NOTE if I ever figure out some cool way of doing this
  # automatically, post it back here https://elixirforum.com/t/batch-delegate-functions-to-a-module/25046
  @api Flamelex.API
  
  defdelegate temet_nosce(), to: @api


end

defmodule Flamelex.API do
  use Flamelex.Lib.ProjectAliases

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

  def redraw_gui do
    # shuts down scenc, starts it & gets GUI controller to attempt to re-draw
    # from scratch
    raise "not implemented"
  end


  @doc """
  #TODO
  Increase or decrease the logging output of Flamelex during runtime.
  """
  def set_log_level(:debug) do
    raise "How do I set the log level??"
  end


  @doc """
  Trigger help for the user.
  """
  def help do
    raise "no help to be found :("
  end
end
