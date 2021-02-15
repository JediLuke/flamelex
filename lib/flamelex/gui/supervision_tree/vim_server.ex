defmodule Flamelex.GUI.VimServer do
  @moduledoc """
  This process holds state for when we use Vim commands.
  """
  use GenServer
  use Flamelex.ProjectAliases


  def start_link(_params) do
    GenServer.start_link(__MODULE__, %{})
  end

  def init(init_state) do
    IO.puts "#{__MODULE__} initializing..."
    Process.register(self(), __MODULE__)
    {:ok, init_state}
  end

  def handle_cast({{:motion, :goto_last_line_in_buffer}, radix_state}, vim_state) do
    IO.puts "HERE WE WILL GO TO THE BOTTOM OF THE FILE!!"
    {:noreply, vim_state}
  end

  def handle_cast({{:verb, v}, radix_state}, vim_state) do
    {:noreply, vim_state}
  end

  def handle_cast({{:noun, v}, radix_state}, vim_state) do
    {:noreply, vim_state}
  end

  def handle_cast({{:modifer, v}, radix_state}, vim_state) do
    {:noreply, vim_state}
  end
end
