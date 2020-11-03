defmodule Flamelex.Memex.Env.JediLuke do
  @moduledoc """
  My primary environment.
  """
  use Flamelex.Memex.EnvironmentBehaviour

  def timezone do
    Memex.Episteme.TimeZones.texas()
  end

  def todo_list do
    JediLuke.TODOlist.all()
  end

  def reminders do
    []
  end

  # def journal do
  #   JediLuke.Journal
  # end

  def on_simple_software do
    ~s(There are some factors which make software simple:

    * low branching factor
    * fits on a slide/page in a presentable fashion with large font
    * concentrate on one thing at a time
    * https://www.youtube.com/watch?v=W2Thd9nKqmU
    * lower the cognitive burdon on those who read it


    )
  end
end
