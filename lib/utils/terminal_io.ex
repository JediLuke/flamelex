defmodule Flamelex.Utilities.TerminalIO do

  #TODO all this

  def warn(string), do: print(:warn, string)

  def print(color, string) when color in [:warn, :light_red] do
    IO.ANSI.light_red()
    IO.puts(string)
    IO.ANSI.default_color()
  end

  #TODO deprecate below
  def red(string) do
    ~s|#{IO.ANSI.red()}#{string}#{IO.ANSI.default_color()}|
  end

  def green(string) do
    IO.puts ~s|#{IO.ANSI.green()}#{string}#{IO.ANSI.default_color()}|
  end

  def light_red(string) do
    IO.puts ~s|#{IO.ANSI.light_red()}#{string}#{IO.ANSI.default_color()}|
  end
end
