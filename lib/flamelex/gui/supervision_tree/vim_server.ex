defmodule Flamelex.GUI.VimServer do
  @moduledoc """
  This process holds state for when we use Vim commands.
  """
  use GenServer
  use Flamelex.ProjectAliases

  def default_state do
    %{
      count: nil    # an optional number that may precede a command = http://vimdoc.sourceforge.net/htmldoc/intro.html#count
    }
  end


  def start_link(_params) do
    GenServer.start_link(__MODULE__, default_state())
  end

  def init(init_state) do
    IO.puts "#{__MODULE__} initializing..."
    Process.register(self(), __MODULE__)
    {:ok, init_state}
  end


  # def handle_cast({{:verb, v}, radix_state}, vim_state) do
  #   {:noreply, vim_state}
  # end

  # def handle_cast({{:noun, v}, radix_state}, vim_state) do
  #   {:noreply, vim_state}
  # end

  # def handle_cast({{:modifer, v}, radix_state}, vim_state) do
  #   {:noreply, vim_state}
  # end


  # http://vimdoc.sourceforge.net/htmldoc/motion.html#jump-motions


  # http://vimdoc.sourceforge.net/htmldoc/motion.html#G
  def handle_cast({{:motion, {:jump, :goto_line}}, radix_state}, %{count: nil} = vim_state) do #NOTE: a count of 1 is the default, no count has been given
    # If you make the cursor "jump" with one of these commands, the
    # position of the cursor before the jump is remembered.

    IO.puts "WE HAVE NO COUNT"

    active_buffer_process =
        radix_state.active_buffer
        |> ProcessRegistry.find!()

    current_cursor_coords = # %Coords{} = #TODO this should be a coords struct
        active_buffer_process
        |> GenServer.call({:get_cursor_coords, 1}) #TODO how do we reference cursors here?

    last_line =
        active_buffer_process
        |> GenServer.call(:get_num_lines)

    # action = {:move_cursor, %{
    #              buffer: radix_state.active_buffer,
    #              details: %{
    #                cursor_num: 1,
    #                goto: %{row: last_line, col: current_cursor_coords.col}}}}

    Flamelex.Fluxus.fire_action({:move_cursor, %{
        buffer: radix_state.active_buffer,
        details: %{
          cursor_num: 1,
          goto: %{line: last_line, col: current_cursor_coords.col}}
    }})

    IO.inspect current_cursor_coords, label: "GOT THE CURENT CURSOR"

    # # You can return to that position with the "''"' and "``" command, #TODO no fkin idea what these characters are lol
    # # unless the line containing that position was changed or deleted. #TODO maybe we can be more clever here

    {:noreply, vim_state |> Map.merge(%{last_cursor: current_cursor_coords})}

    # {:noreply, vim_state}
  end


  # http://vimdoc.sourceforge.net/htmldoc/intro.html#[count]
  def handle_cast({{:motion, {:jump, :goto_line}}, radix_state}, %{count: x} = vim_state)
    when is_integer(x) and x >= 1 do

      # if x >= 2, we do indeed have a count so that modifies the behaviour of :goto_line

    IO.puts "JUMP TO LINE BUT YES WE HAVE A COUNT"

    # here what we want to do, is jump the cursor down x lines, because
    # we have a count in our vim_state, so that's just what we do

    {:noreply, vim_state |> reset_count()}

    # IO.inspect radix_state
    # # If you make the cursor "jump" with one of these commands, the
    # # position of the cursor before the jump is remembered.
    # current_cursor_coords =
    #     radix_state.active_buffer
    #     |> ProcessRegistry.find!()
    #     |> GenServer.call({:get_cursor_coords, 1}) #TODO how do we reference cursors here?

    # # You can return to that position with the "''"' and "``" command, #TODO no fkin idea what these characters are lol
    # # unless the line containing that position was changed or deleted. #TODO maybe we can be more clever here

    # {:noreply, vim_state |> Map.merge(%{last_cursor: current_cursor_coords})}

  end

  # http://vimdoc.sourceforge.net/htmldoc/intro.html#[count]
  def handle_cast({{:integer, x}, _radix_state}, %{count: nil} = vim_state)
    when is_integer(x) and x >= 1 do
      {:noreply, %{vim_state|count: x}}
  end

  def handle_cast({{:integer, x}, _radix_state}, %{count: count} = vim_state)
    when is_integer(count) and
         is_integer(x) and
         x >= 1 do

         #TODO we need to concatenate them here, e.g. if I put in 2 then 3,
         # i want the count to be 23

      {:noreply, %{vim_state|count: x}}
  end


  # private functions


  defp goto_line(vim_state) do

  end

  defp reset_count(%{count: _old_count} = vim_state) do
    # If no number is given, a count of one is used, unless otherwise noted.
    %{vim_state|count: nil}
  end

end
