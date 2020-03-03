defmodule Utilities.ANSIWrite do

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
