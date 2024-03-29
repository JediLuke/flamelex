defmodule Flamelex.DevTools do

    @doc """
    Returns the current input mode.
    """
    def current_mode do
      radix = GenServer.call(Flamelex.FluxusRadix, :get_state)
      radix.mode
    end

    def switch_mode(m) do
      Flamelex.FluxusRadix
      |> GenServer.cast({:action, {:switch_mode, m}})
    end

    def widget_workbench do
        IO.puts "WWE let's get ready to rumble!!"
        Flamelex.Fluxus.action({Flamelex.Fluxus.RadixReducer, {:widget_wkb, :open}})
    end

    def refresh_menubar do
        Flamelex.GUI.Component.MenuBar.refresh()
    end

    def get_radix_state do
        Flamelex.Fluxus.RadixStore.get()
    end

    @doc """
  This function retrieves the default module information, presented by
  the Eixir module. It should work similarly to `IEx.Helpers.h/1`
  """
  def query_module(m) do
    help = IEx.Helpers.h m
    IO.puts "-------------"
    IO.puts help
    help
  end
end

defmodule Flamelex.API.DevTools.SubMenuTestOne do

    def test_fn_one do
        IO.puts "module: #{inspect __MODULE__} fire one!"
    end

    def test_fn_two do
        IO.puts "module: #{inspect __MODULE__} fire two!"
    end

end

defmodule Flamelex.API.DevTools.SubMenuTest_2 do

    def test_fn_one do
        IO.puts "module: #{inspect __MODULE__} fire one!"
    end

    def test_fn_two do
        IO.puts "module: #{inspect __MODULE__} fire two!"
    end

end

defmodule Flamelex.API.DevTools.SubMenuTest_2.EvenMoreSubMenus do

    def test_fn_one do
        IO.puts "module: #{inspect __MODULE__} fire one!"
    end

    def test_fn_two do
        IO.puts "module: #{inspect __MODULE__} fire two!"
    end

end

defmodule Flamelex.API.DevTools.SubMenuTest_3 do

    def test_fn_one do
        IO.puts "module: #{inspect __MODULE__} fire one!"
    end

    def test_fn_two do
        IO.puts "module: #{inspect __MODULE__} fire two!"
    end
end