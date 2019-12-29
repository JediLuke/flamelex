defmodule FranklinTest do
  use ExUnit.Case
  doctest Franklin

  test "greets the world" do
    assert Franklin.hello() == :world
  end
end
