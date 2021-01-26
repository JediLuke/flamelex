defmodule Flamelex.Fluxus.Reducers.Buffer do
  use Flamelex.Fluxux.ReducerBehaviour
  alias Flamelex.Buffer.BufUtils


  def async_reduce(_radix_state,
    {:open_buffer, {:local_text_file, path: filepath}, opts}
  ) when is_map(opts) do

    opts = Map.merge(opts, %{
      type: Flamelex.Buffer.Text, #TODO yuck
      from_file: filepath,
      open_in_gui?: true, #TODO remove
    })

    buf = Flamelex.Buffer.open!(filepath, opts)

    if BufUtils.open_this_buffer_in_gui?(opts) do
      :ok = Flamelex.GUI.Controller.show(buf)
    end

    #TODO call back to FluxusRadix with results of opening
  end


  def async_reduce(_radix_state, {:action, a}) do
    IO.puts "#{__MODULE__} ignoring action: #{inspect a}"
    :ok
  end
end





  # def execute_action_async(%RadixState{} = radix_state, {:active_buffer, :move_cursor, %{to: :last_line}}) do
  #   #TODO find active buffer
  #   #TODO then move the cursor to the last line



  #   Flamelex.FluxusRadix |> send({:ok, radix_state})
  # end
