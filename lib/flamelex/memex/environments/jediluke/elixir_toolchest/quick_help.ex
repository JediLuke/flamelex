defmodule Flamelex.Memex.Env.JediLuke.ElixirToolChest.QuickHelp do

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

  def on_the_topic_of_new_vs_init_for_structs do
    ~s/
    I have decided that it is best to have a `new` function on all structs.
    Almost everyone does this in some form or another, so we should

    Where applicacable, you can have an init function, but it should just
    call new_0
    /
  end

  def on_the_topic_of_extending_structs_in_elixir do
    ~s|
    We should be more interested in using high-level structs, rather than
    low-level types, if we want to build skyscrapers anyway.

    thus the idea is that we shoul dbe able to extend structs

    defstruct vehicle do
      num_wheels:
      horsepower:
    end

    defstruct car extends vehicle do

    end

    defstruct boat extends vehicle do

    end

    then you can make a new car, like so

    c = Car.new(:ferrari)

    4 = c.num_wheels

    It's just old-school OO principles, but applied to the data & in a
    functional language.

    |
  end

  def deeply_nested_maps do
    ~s{put_in(my_map.foo.bar.baz, "new value")}
  end
end
