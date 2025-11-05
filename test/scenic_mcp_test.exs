defmodule ScenicMcpTest do
  use ExUnit.Case

  test "ScenicMcp.Probes module loads with all functions" do
    {:module, ScenicMcp.Probes} = Code.ensure_loaded(ScenicMcp.Probes)
    
    exports = ScenicMcp.Probes.module_info(:exports)
    IO.puts "\nAvailable functions: #{inspect(exports)}"
    
    # Check if take_screenshot functions are available
    screenshot_functions = Enum.filter(exports, fn {name, _arity} -> name == :take_screenshot end)
    IO.puts "Screenshot functions: #{inspect(screenshot_functions)}"
    
    assert Enum.any?(screenshot_functions), "take_screenshot function should be available"
  end
end