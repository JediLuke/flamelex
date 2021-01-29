defmodule Flamelex.Buffer do
  @moduledoc """
  Flamelex.Buffer exposes the Buffer functionality.

  Users should never call this directly! Users go through APIs, which fire
  actions - and inside the reducers, that's where these functions will
  get called.
  """
  alias Flamelex.BufferManager


  def open!(%{type: Flamelex.Buffer.Text, from_file: filepath} = opts) when is_bitstring(filepath) do
    IO.puts "Loading new text buffer for file: #{inspect filepath}..."

    case GenServer.call(BufferManager, {:open_buffer, opts}) do
         {:ok, %Flamelex.Structs.BufRef{} = buf} ->
            buf
         {:error, {:already_started, _pid}} ->
            raise "Here we should just link to the alrdy open pid"
         {:error, reason} ->
            raise "dunno lol - #{inspect reason}"
    end
  end

  #TODO
#   def show
#   def hide

  #TODO use TextCursor structs
#   def move_cursor(%BufRef{} = buf, %Cursor{num: 1}, %{to: destination}) do
#    #TODO call the pid, & give them the instructions

#   end



end
