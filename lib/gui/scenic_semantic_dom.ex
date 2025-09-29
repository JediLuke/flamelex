defmodule Flamelex.GUI.ScenicSemanticDOM do
  @moduledoc """
  Consolidated semantic DOM tools for Flamelex.
  
  This module provides a unified interface for working with semantic annotations
  in Scenic components. It handles:
  
  - Querying semantic elements
  - Adding semantic annotations to graphs
  - Extracting semantic data from ViewPort state
  - Converting between different semantic formats
  """
  
  require Logger
  
  @doc """
  Query the semantic DOM for elements matching the given criteria.
  
  ## Examples
  
      # Find all buttons
      query(%{type: :button})
      
      # Find clickable menu items
      query(%{type: :menu_item, clickable: true})
      
      # Find elements by label pattern
      query(%{label: ~r/Save/i})
      
      # Custom filter function
      query(fn elem -> elem.semantic[:state][:selected] == true end)
  """
  def query(criteria) when is_map(criteria) do
    viewport_pid = Process.whereis(:main_viewport)
    
    if viewport_pid do
      viewport_state = :sys.get_state(viewport_pid)
      semantic_entries = :ets.tab2list(viewport_state.semantic_table)
      
      find_matching_elements(semantic_entries, criteria)
    else
      Logger.warning("Main viewport not found - cannot query semantic DOM")
      []
    end
  end
  
  def query(filter_fn) when is_function(filter_fn, 1) do
    viewport_pid = Process.whereis(:main_viewport)
    
    if viewport_pid do
      viewport_state = :sys.get_state(viewport_pid)
      semantic_entries = :ets.tab2list(viewport_state.semantic_table)
      
      Enum.flat_map(semantic_entries, fn {_key, info} ->
        if is_map(info) && Map.has_key?(info, :elements) do
          info.elements
          |> Map.values()
          |> Enum.filter(filter_fn)
        else
          []
        end
      end)
    else
      Logger.warning("Main viewport not found - cannot query semantic DOM")
      []
    end
  end
  
  @doc """
  Add a semantic annotation to a graph element.
  
  ## Examples
  
      graph
      |> add_semantic_annotation(:my_button, %{
        type: :button,
        role: :button,
        label: "Save",
        clickable: true
      })
  """
  def add_semantic_annotation(graph, element_id, semantic_data) do
    # Add a hidden text element with semantic data
    graph
    |> Scenic.Primitives.text("",
      id: {:semantic, element_id},
      hidden: true,
      semantic: semantic_data
    )
  end
  
  @doc """
  Add multiple semantic annotations at once.
  """
  def add_semantic_annotations(graph, annotations) do
    Enum.reduce(annotations, graph, fn {id, semantic_data}, g ->
      add_semantic_annotation(g, id, semantic_data)
    end)
  end
  
  @doc """
  Extract all semantic elements from the current viewport.
  """
  def get_all_semantic_elements do
    viewport_pid = Process.whereis(:main_viewport)
    
    if viewport_pid do
      viewport_state = :sys.get_state(viewport_pid)
      semantic_entries = :ets.tab2list(viewport_state.semantic_table)
      
      Enum.flat_map(semantic_entries, fn {_key, info} ->
        if is_map(info) && Map.has_key?(info, :elements) do
          Map.values(info.elements)
        else
          []
        end
      end)
    else
      []
    end
  end
  
  @doc """
  Find a single element by its semantic ID.
  """
  def find_by_id(semantic_id) do
    get_all_semantic_elements()
    |> Enum.find(fn elem ->
      elem[:id] == semantic_id || elem[:semantic][:id] == semantic_id
    end)
  end
  
  @doc """
  Find elements by their semantic type.
  """
  def find_by_type(type) do
    query(%{type: type})
  end
  
  @doc """
  Find elements by their label (exact match or regex).
  """
  def find_by_label(label) when is_binary(label) do
    query(%{label: label})
  end
  
  def find_by_label(regex = %Regex{}) do
    query(fn elem ->
      label = elem[:semantic][:label] || ""
      label =~ regex
    end)
  end
  
  @doc """
  Find all clickable elements.
  """
  def find_clickable do
    query(%{clickable: true})
  end
  
  @doc """
  Find menu items by their hierarchical path.
  
  ## Examples
  
      # Find "Memelex > my TODOs"
      find_menu_item([3, 2])
      
      # Find all items under Memelex menu
      find_menu_item([3, :any])
  """
  def find_menu_item(menu_index) do
    query(fn elem ->
      elem[:semantic][:type] == :menu_item &&
      match_menu_index?(elem[:semantic][:menu_index], menu_index)
    end)
  end
  
  @doc """
  Get a summary of all semantic elements in the DOM.
  """
  def summarize do
    elements = get_all_semantic_elements()
    
    summary = %{
      total_count: length(elements),
      by_type: group_by_type(elements),
      clickable_count: count_clickable(elements),
      menu_items: count_menu_items(elements)
    }
    
    IO.puts("\nSemantic DOM Summary:")
    IO.puts("====================")
    IO.puts("Total elements: #{summary.total_count}")
    IO.puts("Clickable elements: #{summary.clickable_count}")
    IO.puts("Menu items: #{summary.menu_items}")
    IO.puts("\nElements by type:")
    
    Enum.each(summary.by_type, fn {type, count} ->
      IO.puts("  #{type}: #{count}")
    end)
    
    summary
  end
  
  @doc """
  Debug helper to print semantic element details.
  """
  def inspect_element(element) do
    semantic = element[:semantic] || %{}
    
    IO.puts("\n=== Semantic Element ===")
    IO.puts("ID: #{inspect(element[:id])}")
    IO.puts("Type: #{semantic[:type]}")
    IO.puts("Role: #{semantic[:role]}")
    IO.puts("Label: #{semantic[:label]}")
    
    if semantic[:description] do
      IO.puts("Description: #{semantic[:description]}")
    end
    
    if semantic[:menu_index] do
      IO.puts("Menu Index: #{inspect(semantic[:menu_index])}")
    end
    
    if semantic[:state] do
      IO.puts("State: #{inspect(semantic[:state])}")
    end
    
    IO.puts("Clickable: #{semantic[:clickable] || false}")
    IO.puts("====================\n")
    
    element
  end
  
  # Private helpers
  
  defp find_matching_elements(semantic_entries, criteria) do
    Enum.flat_map(semantic_entries, fn {_key, info} ->
      if is_map(info) && Map.has_key?(info, :elements) do
        info.elements
        |> Map.values()
        |> Enum.filter(fn elem ->
          matches_criteria?(elem, criteria)
        end)
      else
        []
      end
    end)
  end
  
  defp matches_criteria?(element, criteria) do
    semantic = element[:semantic] || %{}
    
    Enum.all?(criteria, fn {key, expected} ->
      actual = semantic[key]
      
      case expected do
        %Regex{} -> actual && actual =~ expected
        _ -> actual == expected
      end
    end)
  end
  
  defp match_menu_index?(actual_index, pattern_index) do
    case {actual_index, pattern_index} do
      {nil, _} -> false
      {actual, pattern} when actual == pattern -> true
      {[h1 | t1], [h2 | t2]} when h1 == h2 -> match_menu_index?(t1, t2)
      {[_ | _], [:any | t2]} -> match_menu_index?([], t2)
      _ -> false
    end
  end
  
  defp group_by_type(elements) do
    elements
    |> Enum.map(fn elem -> elem[:semantic][:type] end)
    |> Enum.reject(&is_nil/1)
    |> Enum.frequencies()
  end
  
  defp count_clickable(elements) do
    Enum.count(elements, fn elem ->
      elem[:semantic][:clickable] == true
    end)
  end
  
  defp count_menu_items(elements) do
    Enum.count(elements, fn elem ->
      elem[:semantic][:type] == :menu_item
    end)
  end
end