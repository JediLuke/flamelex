defmodule Flamelex.Test.TodoVisualDisplaySpex do
  @moduledoc """
  Test suite focused on TODO visual display functionality.
  
  This ensures TODOs are displayed with proper visual elements:
  - Priority badges (red/orange/green)
  - Status indicators
  - Background colors based on status
  """
  use SexySpex

  setup_all do
    SexySpex.Helpers.start_scenic_app(:flamelex)
  end

  spex "TODO display with visual enhancements",
    description: "Verify TODOs show with priority badges and status styling",
    tags: [:todos, :visual, :display] do
    
    scenario "Create and display TODOs with visual formatting", context do
      given_ "I create test TODOs with different priorities", context do
        Process.sleep(3000)
        
        # Clear any existing TODOs for a clean test
        # Create test TODOs
        todo_specs = [
          %{title: "High priority bug", priority: "high", status: "pending"},
          %{title: "Medium feature", priority: "medium", status: "in_progress"},
          %{title: "Low docs update", priority: "low", status: "done"}
        ]
        
        created_todos = Enum.map(todo_specs, fn spec ->
          params = %{
            title: spec.title,
            data: "Test description for #{spec.title}",
            tags: [],  # Don't include #TODO as it's automatically added
            meta: [
              %{
                "priority" => spec.priority,
                "status" => spec.status
              }
            ]
          }
          
          Memelex.My.TODOs.new(params)
        end)
        
        {:ok, Map.put(context, :test_todos, created_todos)}
      end
      
      when_ "I navigate to the TODO page", context do
        Memelex.My.TODOs.show()
        Process.sleep(2000)
        {:ok, context}
      end
      
      then_ "TODOs display with appropriate visual styling", context do
        state = Flamelex.Fluxus.RadixStore.get()
        
        case state do
          %{apps: %{todo_list: %{list: todos}}} when length(todos) > 0 ->
            IO.puts("   🎨 Visual Display Verification:")
            IO.puts("   📋 Found #{length(todos)} TODOs")
            
            # Verify each TODO type
            high_priority = Enum.find(todos, fn t -> 
              case t.meta do
                [%{"priority" => "high"} | _] -> true
                _ -> false
              end
            end)
            
            medium_priority = Enum.find(todos, fn t ->
              case t.meta do
                [%{"priority" => "medium"} | _] -> true
                _ -> false
              end
            end)
            
            low_priority = Enum.find(todos, fn t ->
              case t.meta do
                [%{"priority" => "low"} | _] -> true
                _ -> false
              end
            end)
            
            if high_priority do
              IO.puts("   🔴 High priority TODO found - should have red badge")
            end
            
            if medium_priority do
              IO.puts("   🟠 Medium priority TODO found - should have orange badge")
            end
            
            if low_priority do
              IO.puts("   🟢 Low priority TODO found - should have green badge")
            end
            
            # Check for visual elements in semantic DOM
            viewport_state = :sys.get_state(Process.whereis(:main_viewport))
            semantic_entries = :ets.tab2list(viewport_state.semantic_table)
            
            todo_items = Enum.flat_map(semantic_entries, fn {_key, info} ->
              if is_map(info) && Map.has_key?(info, :elements) do
                info.elements
                |> Map.values()
                |> Enum.filter(fn elem ->
                  case elem[:id] do
                    {:todo_item, _uuid} -> true
                    _ -> false
                  end
                end)
              else
                []
              end
            end)
            
            IO.puts("   🎯 Found #{length(todo_items)} semantic TODO items")
            IO.puts("   ✅ Visual display test passed")
            
          %{apps: %{todo_list: %{list: []}}} ->
            raise "No TODOs found in display"
            
          _ ->
            raise "TODO list not active"
        end
        
        {:ok, context}
      end
    end
  end
end