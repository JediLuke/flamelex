defmodule Flamelex.API.ScriptAnalysis.ScriptInterceptorDriver do
  @moduledoc """
  A custom Scenic driver that wraps Scenic.Driver.Local to intercept
  and analyze script data before it reaches the native driver.
  
  This allows us to capture, log, and analyze all rendering commands
  in real-time for debugging and performance analysis.
  """
  
  # use Scenic.Driver  # Temporarily commented due to compilation issues
  require Logger
  
  alias Scenic.Driver.Local, as: LocalDriver
  alias Flamelex.API.ScriptAnalysis.ScriptAnalyzer
  
  # Delegate most driver behavior to the original Local driver
  defdelegate validate_opts(opts), to: LocalDriver
  
  @doc false
  @impl Scenic.Driver
  def init(driver, opts) do
    Logger.info("#{__MODULE__}: Initializing script interceptor driver")
    
    # Initialize the script analyzer
    ScriptAnalyzer.start_link()
    
    # Initialize the underlying Local driver
    LocalDriver.init(driver, opts)
  end
  
  # Intercept script-related callbacks
  @doc false
  @impl Scenic.Driver
  def reset_scene(driver) do
    Logger.debug("#{__MODULE__}: reset_scene intercepted")
    ScriptAnalyzer.log_event(:reset_scene, %{timestamp: System.monotonic_time()})
    LocalDriver.reset_scene(driver)
  end
  
  @doc false
  @impl Scenic.Driver
  def update_scene(ids, driver) do
    Logger.debug("#{__MODULE__}: update_scene intercepted - ids: #{inspect(ids)}")
    
    # Capture script data before it goes to the driver
    script_data = capture_script_data(ids, driver)
    ScriptAnalyzer.analyze_scripts(script_data)
    
    # Pass through to the original driver
    LocalDriver.update_scene(ids, driver)
  end
  
  @doc false
  @impl Scenic.Driver
  def del_scripts(ids, driver) do
    Logger.debug("#{__MODULE__}: del_scripts intercepted - ids: #{inspect(ids)}")
    ScriptAnalyzer.log_event(:del_scripts, %{ids: ids, timestamp: System.monotonic_time()})
    LocalDriver.del_scripts(ids, driver)
  end
  
  @doc false
  @impl Scenic.Driver
  def clear_color(color, driver) do
    Logger.debug("#{__MODULE__}: clear_color intercepted - color: #{inspect(color)}")
    ScriptAnalyzer.log_event(:clear_color, %{color: color, timestamp: System.monotonic_time()})
    LocalDriver.clear_color(color, driver)
  end
  
  # Delegate all GenServer callbacks to the original driver
  @doc false
  @impl GenServer
  def handle_call(msg, from, driver) do
    LocalDriver.handle_call(msg, from, driver)
  end
  
  @doc false
  @impl GenServer
  def handle_cast(msg, driver) do
    LocalDriver.handle_cast(msg, driver)
  end
  
  @doc false
  @impl GenServer
  def handle_info(msg, driver) do
    LocalDriver.handle_info(msg, driver)
  end
  
  # Private functions
  
  defp capture_script_data(ids, %{viewport: vp}) do
    Enum.map(ids, fn id ->
      case Scenic.ViewPort.get_script(vp, id) do
        {:ok, script} ->
          serialized = Scenic.Script.serialize(script)
          # Handle case where serialized might be a list of binaries
          size = case serialized do
            bin when is_binary(bin) -> byte_size(bin)
            list when is_list(list) -> 
              list 
              |> Enum.map(&IO.iodata_length/1) 
              |> Enum.sum()
            _ -> 0
          end
          
          %{
            id: id,
            script: script,
            serialized: serialized,
            size: size,
            timestamp: System.monotonic_time()
          }
        _ ->
          %{id: id, error: :script_not_found, timestamp: System.monotonic_time()}
      end
    end)
  end
end
