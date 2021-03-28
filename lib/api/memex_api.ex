defmodule Flamelex.API.Memex do
  @moduledoc """
  The interface to the Memex.
  """
  use Flamelex.ProjectAliases


  @doc """
  This function must return the Module name for the Memex.Environment
  being used.
  """
  def current_env do
    Flamelex.Memex.Env.JediLuke #TODO this should be via config!
  end


  defmodule My do
    @moduledoc """
    This module proves an interface for retrieving information from the
    Memex which is unique to the loaded environment.
    """
    alias Flamelex.API.Memex

    def todos,        do: my().todo_list()
    def current_time, do: my().timezone() |> DateTime.now!()

    defp my(), do: Memex.current_env()
  end


  # def save_memex_file do
  #   DataFile.read()
  #     |> Map.merge(%{
  #          state.uuid => %{
  #            title: state.title,
  #            text: state.text,
  #            datetime_utc: DateTime.utc_now(),
  #            #TODO hash entire contents
  #            #TODO handle timezones
  #            tags: ["note"]
  #          },
  #        })
  #     |> DataFile.write()
  # end

  def set_env do
    raise "right now, no way to change your environment unfortuntely"
  end

  def open_catalog do
    #TODO this should open, in a buffer, just like anything else
    raise "the Memex catalog, is the TidlyWiki-like interface to the Memex"
  end

  @doc """
  Look in the memex & return a random %LiteraryQuote{}.
  """
  def random_quote do
    Enum.random(
         Flamelex.Memex.Episteme.AncientAlchemy.quotes()
      ++ Flamelex.Memex.Episteme.BenjaminFranklin.quotes()
      ++ Flamelex.Memex.Episteme.ProgrammingLanguages.ElixirLang.quotes()
    )
  end
end
