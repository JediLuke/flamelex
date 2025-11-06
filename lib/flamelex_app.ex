defmodule Flamelex.App do
  @moduledoc false
  use Application
  require Logger

  def start(_type, _args) do
    Logger.debug("#{__MODULE__} initializing...")

    boot_mmlx? = boot_memelex?()

    init_args =
      if boot_mmlx? do
        Logger.debug("attempting to boot Memex...")
        :ok = start_memelex()
        %{memex: %{active?: boot_mmlx?}}
      else
        Logger.debug("starting Flamelex (no Memex)...")
        %{memex: %{active?: boot_mmlx?}}
      end

    start_quillex()

    children = start_flamelex(init_args)

    opts = [strategy: :one_for_one, name: __MODULE__]
    Supervisor.start_link(children, opts)
  end

  def restart do
    # IEx.recompile()
    Application.stop(:flamelex) && Application.start(:flamelex)
  end

  def boot_memelex? do
    Application.get_env(:memelex, :active?, false)
  end

  defp start_memelex do
    # we don't automatically boot memelex the way an app usually just
    # automatically gets booted for simply being one of the deps in mix.exs
    # because not every person using Flamelex has a memex yet,
    # so we use this environment/config variable to control how memelx gets booted

    # Memelex may run as a standalone application, in which case it needs it's own
    # event listening code, or it may run embedded from within Flamelex, in which case
    # Flamelex will listen to Memelex events & handle them (and any interactions with
    # external systems). So if we (Memelex) were started by Flamelex, don't boot the Event listeners.

    Application.put_env(:memelex, :started_by_flamelex?, true)
    {:ok, _apps_started} = Application.ensure_all_started(:memelex)
    :ok
  end

  defp start_quillex do
    # in mix.exs we disabled booting the Quillex app/sup-tree (runtime: false)
    # because it will automatically boot it's own GUI (and this happens
    # before we ever get a chance to set the environment variable below,
    # because deps get booted first) but once we have set the variable
    # which disables the GUI (& controls a couple of other things, like how
    # quillex routes event - if booted by flamelex, events need to propagate
    # back up to flamelex), we should go ahead and boot Quillex
    Application.put_env(:quillex, :started_by_flamelex?, true)
    {:ok, _apps_started} = Application.ensure_all_started(:quillex)
    :ok
  end

  defp start_flamelex(args) do
    children = [
      flamelex_pubsub_broker(),
      {Flamelex.Fluxus.Supervisor, args},
      {Scenic, [Flamelex.GUI.viewport_config()]}
    ]

    # Conditionally start Tidewave MCP server for development
    children = children ++
      if Mix.env() == :dev and Code.ensure_loaded?(Tidewave) and Code.ensure_loaded?(Bandit) do
        Logger.info("Starting Tidewave MCP server on port 4000")
        [{Bandit, plug: Tidewave, port: 4000}]
      else
        []
      end

    children
  end

  defp flamelex_pubsub_broker do
    # https://hexdocs.pm/elixir/1.12/Registry.html#module-using-as-a-dispatcher
    {Registry, keys: :duplicate, name: Flamelex.Fluxus.PubSub}
  end
end


# TODO apps

# messenging app
# gilbertex (paint / freehand drawing app)
# graph visualizer / neural-net workbench
