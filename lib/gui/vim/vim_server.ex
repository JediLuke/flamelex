defmodule Flamelex.GUI.VimServer do
  @moduledoc """
  This process holds state for when we use Vim commands.
  """
  use GenServer
  use Flamelex.ProjectAliases
  require Logger

  def default_state do
    %{
      count: nil    # an optional number that may precede a command = http://vimdoc.sourceforge.net/htmldoc/intro.html#count
    }
  end


  def start_link(_params) do
    GenServer.start_link(__MODULE__, default_state())
  end

  def init(init_state) do
    #Logger.debug "#{__MODULE__} initializing..."
    Process.register(self(), __MODULE__)
    {:ok, init_state}
  end


  @doc """
  Queries Flamelex to get some details about the active buffer, and the
  position of the first cursor.
  """
  def fetch_active_cursor(radix_state) do

    active_buffer_pid = radix_state.active_buffer
                        |> ProcessRegistry.find!()

    current_cursor_coords = # %Coords{} = #TODO this should be a coords struct
                            active_buffer_pid
                            |> GenServer.call({:get_cursor_coords, 1}) #TODO how do we reference cursors here?

    %{
      active_buffer: %{
        rego: radix_state.active_buffer,
        pid: active_buffer_pid
      },
      cursor_coords: current_cursor_coords
    }
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





  # http://vimdoc.sourceforge.net/htmldoc/insert.html#inserting
  #TODO need to take count into affect - http://vimdoc.sourceforge.net/htmldoc/insert.html#o - repeat [count] times
  #TAKES COUNT - opens up 5 cursors on 5 lines !!
  def handle_cast({{:inserting, {:open_a_new_line, :below_the_current_line}}, radix_state}, vim_state) do
    # http://vimdoc.sourceforge.net/htmldoc/insert.html#o
    # The following commands can be used to insert new text into the buffer.
    # They can all be undone and repeated with the "." command.
    # IO.puts "for now, just open below current line... every time"

    # 2 - insert newline character at end
    # 1 - open insert mode

    active_buffer_process =
      radix_state.active_buffer
      |> ProcessRegistry.find!()

    current_cursor_coords = # %Coords{} = #TODO this should be a coords struct
      active_buffer_process
      |> GenServer.call({:get_cursor_coords, 1}) #TODO how do we reference cursors here?

    # IO.puts "OPENINENINGING - #{inspect current_cursor_coords}"

    Flamelex.Fluxus.fire_actions([
      # append a new line to the current line
      {:modify_buf, %{
          buffer: radix_state.active_buffer,
          details: %{
            line: current_cursor_coords.line,
            append: "\n" # a newline character
          }
      }},
      # move the cursor down to the new line we just created
      {:move_cursor, %{
          buffer: radix_state.active_buffer,
          details: %{
            cursor_num: 1,
            instructions: {:down, 1, :line}
          }
      }},
      # then, switch into insert mode
      {:switch_mode, :insert} #TODO don't use global modes, this should only affect the local buffer
    ])


    {:noreply, vim_state}
  end

  # move the cursor to the end of the current line, and enter insert mode
  def handle_cast({{:append, :end_of_current_line}, radix_state}, vim_state) do
    %{cursor_coords: %{line: l}} = fetch_active_cursor(radix_state)

    Flamelex.Fluxus.fire_actions([
      # move the cursor down to the new line we just created
      {:move_cursor, %{
          buffer: radix_state.active_buffer,
          details: %{
            cursor_num: 1,
            instructions: {:last_col, :line, l}
          }
      }},
      # then, switch into insert mode
      {:switch_mode, :insert} #TODO don't use global modes
    ])

    {:noreply, vim_state}
  end

  # http://vimdoc.sourceforge.net/htmldoc/motion.html#G
  def handle_cast({{:motion, {:jump, :goto_line}}, radix_state}, %{count: nil} = vim_state) do #NOTE: a count of 1 is the default, no count has been given
    # If you make the cursor "jump" with one of these commands, the
    # position of the cursor before the jump is remembered. #TODO

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
          instructions: {:goto, %{line: last_line, col: current_cursor_coords.col}}
    }}})


    # # You can return to that position with the "''"' and "``" command, #TODO no fkin idea what these characters are lol
    # # unless the line containing that position was changed or deleted. #TODO maybe we can be more clever here

    {:noreply, vim_state |> Map.merge(%{last_cursor: current_cursor_coords})}

    # {:noreply, vim_state}
  end




  # http://vimdoc.sourceforge.net/htmldoc/intro.html#[count]
  def handle_cast({{:motion, {:jump, :goto_line}}, radix_state}, %{count: x} = vim_state)
    when is_integer(x) and x >= 1 do

      # if x >= 2, we do indeed have a count so that modifies the behaviour of :goto_line

    # here what we want to do, is jump the cursor down x lines, because
    # we have a count in our vim_state, so that's just what we do

    {:noreply, vim_state |> reset_count()}

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
