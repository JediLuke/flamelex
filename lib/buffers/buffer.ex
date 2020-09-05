defmodule Flamelex.Buffer do
  @moduledoc """
  The interface to all the Buffer commands.
  """
  require Logger


  def load(type: :text, file: filepath) when is_bitstring(filepath) do
    Logger.info "Loading new text buffer for file: #{inspect filepath}"
    content = File.read!(filepath)
    Flamelex.Buffer.Supervisor.start_buffer_process(
                      type: :text, name: filepath, content: content)
  end

  # def update_content(%Buffer{} = buf, with: c) do
  #   %{buf|content: c}
  # end
end
