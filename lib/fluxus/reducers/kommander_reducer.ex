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

   def process(%{kommander: %{buffer: %{cursors: [cursor]} = k_buf}} = radix_state, {:modify_kommander, {:backspace, 1, :at_cursor}}) do
      #TODO this is a dodgy implementation which only assumes one line...
      if cursor.col == 1 do
         :ignore
      else
         {before_cursor_text, after_and_under_cursor_text} = k_buf.data |> String.split_at(cursor.col-1)
         {backspaced_text, _deleted_text} = before_cursor_text |> String.split_at(-1)

         full_backspaced_line = backspaced_text <> after_and_under_cursor_text

         new_k_buf =
            %{k_buf|data: full_backspaced_line}
            |> QuillEx.Structs.Buffer.update(%{cursor: %{line: cursor.line, col: cursor.col-1}})

         new_radix_state =
            radix_state
            |> put_in([:kommander, :buffer], new_k_buf)

         {:ok, new_radix_state}
      end
   end

   def process(radix_state, :execute) do

      # IO.inspect radix_state.kommander.buffer.data
      {:ok, _pid} = Task.start(fn ->
         res = Code.eval_string(radix_state.kommander.buffer.data, [], __ENV__)
         IO.inspect res, label: "KOMMANDER"
      end)

      # {value, _binding} = Task.await(eval_task)
      # IO.inspect value, label: "Kommander result"

      :ok
   end

   def process(%{kommander: %{buffer: k_buf}} = radix_state, :clear) do
      new_radix_state =
         radix_state |> put_in([:kommander, :buffer], %{k_buf|data: ""})

      {:ok, new_radix_state}
   end
   

   def process(radix_state, action) do
      IO.puts "#{__MODULE__} failed to process action: #{inspect action}"
      dbg()
   end

end
  