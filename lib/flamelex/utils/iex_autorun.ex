defmodule Flamelex.IExAutoRun do
  @moduledoc """
  This Elixir code will automatically be run when the Flamelex app starts.

  The `.iex.exs` file in the project is automatically read by mix/IEx
  (I'm not 100% sure exactly which it is...), and if you check that, you
  should see it contains

  Note that it is a *quote*, not a function. This code
  """


  # this macto gets executed whenever the application is started in IEx
  # via the `.iex.exs` file
  defmacro __using__(_) do
    quote do

      IO.puts "Executing the code in `Flamelex.IExAutoRun`, via the `.iex.exs` file..."

      # use Flamelex.ProjectAliases
      alias Flamelex.API.Buffer
      alias Flamelex.API.Kommander
      alias Flamelex.API.Memex
      alias Flamelex.API.Memex.My
      alias Flamelex.API.Journal
      alias Flamelex.API.Buffer
      # alias Flamelex.API.GUI
      # alias Flamelex.API.{Buffer, Kommander, GUI, Memex, Journal}



      Flamelex.IExAutoRun.print_welcome_msg()

    end
  end

  def print_welcome_msg do
    IO.puts("

    Welcome to Flamelex
    -------------------
    v0.2.7

    " <> punctuated_quote())
  end

  def punctuated_quote do
    q = Flamelex.API.Memex.random_quote()

    ~s(“#{q.text}”
     - #{q.author}

    )
  end
end
