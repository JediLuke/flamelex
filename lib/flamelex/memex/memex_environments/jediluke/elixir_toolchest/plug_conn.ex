defmodule Flamelex.Memex.Env.JediLuke.ElixirToolChest.PlugConn do

  def how_to("put a request body in plug_conn") do
    ~s{

    pipe_struct
    |> (& &1 |> IO.inspect).()

    }
  end
end
