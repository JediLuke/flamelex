defmodule Flamelex.Memex.Env.JediLuke.TODOlist do
  @moduledoc """
  My TODOs.
  """
  alias Flamelex.Memex.Env.JediLuke

  def all do
    JediLuke.DubberWork.todo_list()
    ++ JediLuke.Art.list()
    ++ JediLuke.Projects.list()
    ++ australian_tax()
    ++ beauregard_tech()
    ++ apply_at_grad_school()
    ++ flamelex_todos()
    ++ life_admin()
  end

  def australian_tax do
    ["get ruling from ATO"]
  end

  def beauregard_tech do
    [
      "get advertising happening for one on one classes",
      "finish programming 101 course",
      "create Elixir for professionals course",
    ]
  end

  def apply_at_grad_school do
    ["UT", "CarnegieMelon"]
  end

  def flamelex_todos do
    [
      "create TODOs struct inside flamelex"
    ]
  end

  def life_admin do
    [
      "pay telstra bill",
      "move telstra bill to RingCentral",
    ]
  end
end
