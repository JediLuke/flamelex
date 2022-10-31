defmodule Flamelex.Utilities.IExUtils do
  require IEx.Helpers

  @doc """
  This function retrieves the default module information, presented by
  the Eixir module. It should work similarly to `IEx.Helpers.h/1`
  """
  def query_module(m) do
    help = IEx.Helpers.h m
    IO.puts "-------------"
    IO.puts help
    help
  end
end
