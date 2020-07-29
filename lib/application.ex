defmodule Franklin.Application do
  @moduledoc ~S(`Franklin` is a Memex & computation tool written in Elixir.)

  use Application
  require Logger

  @welcome_string ~s(Welcome to Franklin.

  * `help`         :: Get more help.)


  def start(_type, _args) do

    Logger.info @welcome_string

    children = [
      # Franklin.Commander,
      # Franklin.PubSub,
      # Franklin.Buffer.TopLevelSupervisor,
      Franklin.Agent.TopLevelSupervisor,
      {Scenic, viewports: [GUI.Initialize.viewport_config()]}
    ]

    opts = [strategy: :one_for_one, name: Franklin.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
