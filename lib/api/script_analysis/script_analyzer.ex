defmodule Flamelex.API.ScriptAnalysis.ScriptAnalyzer do
  @moduledoc """
  Analyzes and logs Scenic script data for debugging and performance analysis.
  
  This module captures script information, analyzes rendering patterns,
  and provides insights into the GUI rendering pipeline.
  """
  
  use GenServer
  require Logger
  
  @table_name :script_analysis_data
  
  # Client API
  
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end
  
  def analyze_scripts(script_data) do
    GenServer.cast(__MODULE__, {:analyze_scripts, script_data})
  end
  
  def log_event(event_type, data) do
    GenServer.cast(__MODULE__, {:log_event, event_type, data})
  end
  
  def get_stats do
    GenServer.call(__MODULE__, :get_stats)
  end
  
  def get_recent_scripts(limit \\ 10) do
    GenServer.call(__MODULE__, {:get_recent_scripts, limit})
  end
  
  def clear_data do
    GenServer.call(__MODULE__, :clear_data)
  end
  
  # Server callbacks
  
  @impl true
  def init(_opts) do
    Logger.info("#{__MODULE__}: Starting script analyzer")
    
    # Create ETS table for storing script data
    :ets.new(@table_name, [:named_table, :public, :ordered_set])
    
    state = %{
      script_count: 0,
      total_bytes: 0,
      events: [],
      start_time: System.monotonic_time()
    }
    
    {:ok, state}
  end
  
  @impl true
  def handle_cast({:analyze_scripts, script_data}, state) do
    new_state = process_script_data(script_data, state)
    {:noreply, new_state}
  end
  
  @impl true
  def handle_cast({:log_event, event_type, data}, state) do
    event = %{
      type: event_type,
      data: data,
      timestamp: System.monotonic_time()
    }
    
    Logger.debug("Script event: #{event_type} - #{inspect(data)}")
    
    # Keep only the last 100 events to prevent memory bloat
    events = [event | state.events] |> Enum.take(100)
    
    {:noreply, %{state | events: events}}
  end
  
  @impl true
  def handle_call(:get_stats, _from, state) do
    uptime = System.monotonic_time() - state.start_time
    
    stats = %{
      script_count: state.script_count,
      total_bytes: state.total_bytes,
      uptime_ms: System.convert_time_unit(uptime, :native, :millisecond),
      recent_events: Enum.take(state.events, 10),
      avg_script_size: if(state.script_count > 0, do: state.total_bytes / state.script_count, else: 0)
    }
    
    {:reply, stats, state}
  end
  
  @impl true
  def handle_call({:get_recent_scripts, limit}, _from, state) do
    scripts = 
      @table_name
      |> :ets.tab2list()
      |> Enum.sort_by(fn {timestamp, _} -> timestamp end, :desc)
      |> Enum.take(limit)
      |> Enum.map(fn {_timestamp, data} -> data end)
    
    {:reply, scripts, state}
  end
  
  @impl true
  def handle_call(:clear_data, _from, state) do
    :ets.delete_all_objects(@table_name)
    
    new_state = %{
      state | 
      script_count: 0,
      total_bytes: 0,
      events: []
    }
    
    {:reply, :ok, new_state}
  end
  
  # Private functions
  
  defp process_script_data(script_data, state) do
    Enum.reduce(script_data, state, fn script_info, acc ->
      case script_info do
        %{error: _} ->
          Logger.warn("Script analysis error: #{inspect(script_info)}")
          acc
          
        %{id: id, serialized: serialized, size: size} = info ->
          # Store in ETS for later retrieval
          timestamp = System.monotonic_time()
          :ets.insert(@table_name, {timestamp, info})
          
          # Analyze the script content
          analysis = analyze_script_content(serialized)
          
          Logger.debug("Script #{id}: #{size} bytes, #{analysis.command_count} commands")
          
          # Update state
          %{
            acc | 
            script_count: acc.script_count + 1,
            total_bytes: acc.total_bytes + size
          }
      end
    end)
  end
  
  defp analyze_script_content(serialized_script) do
    # Basic analysis of the serialized script
    # This is a simplified analysis - in a full implementation,
    # we'd parse the actual script format
    
    size = byte_size(serialized_script)
    
    # Estimate command count based on script size
    # (This is a rough heuristic - actual parsing would be more accurate)
    estimated_commands = div(size, 8) # Rough estimate
    
    %{
      size: size,
      command_count: estimated_commands,
      complexity: cond do
        size < 100 -> :simple
        size < 1000 -> :moderate
        true -> :complex
      end
    }
  end
end
