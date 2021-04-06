defmodule Flamelex.Memex.EnvironmentBehaviour do
  @moduledoc """
  The Memex can load different environments.
  """

  #NOTE: When we call use Behaviour, we can not only enforce the behaviour
  #      on a module, but we can automatically import functions etc.
  defmacro __using__(_params) do

    quote do
      @behaviour Flamelex.Memex.EnvironmentBehaviour
      use Flamelex.ProjectAliases


      @doc """
      Each environment has to return an id, which is also the module name which
      provides the entry-point into that environment.
      """
      # def id, do: __MODULE__ #NOTE: environments are registered as atoms

      # #NOTE: This is just for convenience, so inside environment modules
      # #      we can easily use the unique part of the environment module name
      # alias __MODULE__

    end
  end


  @doc """
  #TODO rename this field to "name" - is is the name of this environment,
  iit must be unique to this session of Flamelex.
  """
  @callback id() :: String.t()


  @doc """
  Return the current timezone.
  """
  @callback timezone() :: String.t

  @doc """
  We all have things we need to do, and there's no simpler way to keep
  track of them than with a todo_list
  """
  @callback todo_list() :: list()


  @doc """
  A list of all the current reminders in this environment.
  """
  @callback reminders() :: list()

  @doc """
  Return the journal module for this environment.
  """
  # @callback journal() :: atom()
end
