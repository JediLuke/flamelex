defmodule Flamelex.Buffer.Supervisor do
  use DynamicSupervisor


  def start_link(args) do
    DynamicSupervisor.start_link(__MODULE__, args, name: __MODULE__)
  end


  def init(_args) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end


  def start_buffer_process(type: :text, name: name, content: content) do
    DynamicSupervisor.start_child(__MODULE__,
                        {Flamelex.Buffer.Text, {:text, name, content}})
  end

  # def start_buffer(content, of_type: :note) do
  #   #TODO add extra args to GUI, but it's still a text buffer
  #   start_new_buffer_process({TextBuffer, content})
  # end
  # def start_buffer(content, of_type: :whiteboard) do
  #   start_new_buffer_process({WhiteboardBuffer, content})
  # end
  # def start_buffer(content, of_type: :list) do
  #   start_new_buffer_process({ListBuffer, content})
  # end

  # def note(buf_mem, args),   do: start_new_buffer_process({Franklin.Buffer.Note, contents})
  # def list(:notes),     do: start_new_buffer_process({Franklin.Buffer.List, :notes})
  # def whiteboard(args), do: start_new_buffer_process({Franklin.Buffer.Whiteboard, args})

end
