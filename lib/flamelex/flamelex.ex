defmodule Flamelex do
  use Flamelex.ProjectAliases

  @doc """
  Use this function to recompile, reload and restart the `Flamelex` application.

  Flamelex is an interactive thinking-space (manasphere?). It is intended
  to be edited on by the user, and incorporate changes to it's own codebase.
  It is a more refined version of the original Lisp machine. When you make
  changes in your Flamelex code/environment (try to start thinking of those
  two as the same thing), sometimes you need to (safely!) shut-down the
  application & restart it, without losing any state. That is what this
  function is for.

  This function is the heart of the read-eval-print loop - We, the users,
  edit the program, which is then changed. And those changes then affect
  us - our next sentence will be inuot via a slightly different set of
  keystrokes, in order to take advantage of the new functions we have
  created... we go back & forth, input & output, ying & yang, recursion &
  returning. Let your mind expand into the thought-space, and grow as the
  universe intends us to.

  Named for the famous Alchemist, Paracelsus.
  """
  def paracelsize do
    IO.puts "\n#{__MODULE__} stopping..."
    Application.stop(:flamelex)

    IO.puts "\n#{__MODULE__} recompiling..."
    IEx.Helpers.recompile

    IO.puts "\n#{__MODULE__} starting...\n"
    Application.start(:flamelex)
  end


  def set_log_level(l) do
    raise "How do I set the log level??"
  end

  def help do
    raise "no help to be found :("
  end
end
