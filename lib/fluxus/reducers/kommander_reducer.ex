defmodule Flamelex.Fluxus.Reducers.Kommander do
   @moduledoc false
   use Flamelex.ProjectAliases
   require Logger


   def process(radix_state, :show) do
      new_radix_state = radix_state
      |> put_in([:kommander, :hidden?], false)

      {:ok, new_radix_state}
   end

   def process(radix_state, :hide) do
      new_radix_state = radix_state
      |> put_in([:kommander, :hidden?], true)

      {:ok, new_radix_state}
   end

   def process(%{kommander: %{buffer: %{cursors: [old_cursor]} = old_k_buf}} = radix_state, {:modify_kommander, {:insert, text, :at_cursor}}) do

      new_cursor =
         QuillEx.Structs.Buffer.Cursor.calc_text_insertion_cursor_movement(old_cursor, text)

      new_k_buf =
         old_k_buf
         |> QuillEx.Structs.Buffer.update({:insert, text, {:at_cursor, old_cursor}})
         |> QuillEx.Structs.Buffer.update(%{cursor: new_cursor})

      new_radix_state =
         radix_state |> put_in([:kommander, :buffer], new_k_buf)

      {:ok, new_radix_state}
   end

   def process(radix_state, action) do
      IO.puts "#{__MODULE__} failed to process action: #{inspect action}"
      dbg()
   end

end
  