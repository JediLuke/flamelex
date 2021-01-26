defmodule Flamelex.Buffer do
  @moduledoc """
  Flamelex.Buffer exposes the Buffer functionality.
  """
  alias Flamelex.BufferManager


  def open!(filepath, opts \\ %{}) do
    IO.puts "Loading new text buffer for file: #{inspect filepath}..."

    case GenServer.call(BufferManager, {:open_buffer, opts}) do
         {:ok, %Flamelex.Structs.Buf{} = buf} ->
            buf
         {:error, {:already_started, _pid}} ->
            raise "Here we should just link to the alrdy open pid"
         {:error, reason} ->
            raise "dunno lol - #{inspect reason}"
    end
  end

end
