defmodule Flamelex.Memex.Env.JediLuke.ElixirToolChest.GettingANewDateTimeStruct do

  def how_to("use an anonymous function in a pipeline") do
    ~s/
    pipe_struct
    |> (& &1 |> IO.inspect).()
    /
  end

  def use_option_lists do
    ~s/
    defp open_in_gui?(opts) do
      case Keyword.fetch(opts, :show_in_gui?) do
        {:ok, show_in_gui?} -> show_in_gui?
        :error ->           -> false
      end
    end
    /
  end

  def receive_do_msgs do
    # https://www.erlang-solutions.com/blog/receiving-messages-in-elixir-or-a-few-things-you-need-to-know-in-order-to-avoid-performance-issues.html
    ~s/
    receive do
      pattern1 -> :process_message_pattern1
      pattern2 -> :process_message_pattern2
      _othrwse -> :process_catch_all_case
    after
     1000 -> :ok
    end
    /
  end
end
