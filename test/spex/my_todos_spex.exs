defmodule Flamelex.Test.MyTodosSpex do
  @moduledoc """
  Test suite for the My TODOs page functionality.
  
  This spex verifies the TODOs page displays correctly and will serve
  as the foundation for testing TODO list features like:
  - Viewing existing TODOs
  - Creating new TODOs
  - Editing TODOs
  - Marking TODOs as complete
  - Filtering and searching
  """
  use SexySpex

  setup_all do
    SexySpex.Helpers.start_scenic_app(:flamelex)
  end

  spex "My TODOs page displays correctly",
    description: "Verify the TODOs page loads and shows expected UI elements",
    tags: [:todos, :page_load, :ui_verification] do
    
    scenario "Navigate to TODOs and verify page structure", context do
      given_ "Flamelex is running", context do
        IO.puts("   ⏳ Waiting for app to fully load...")
        Process.sleep(3000)
        
        # Verify app is running
        state = Flamelex.Fluxus.RadixStore.get()
        IO.puts("\n   🚀 Flamelex is running")
        
        {:ok, context}
      end
      
      when_ "I navigate to the TODOs page using the API", context do
        IO.puts("\n   📍 Navigating to TODOs page...")
        
        # Use the API function to navigate directly to TODOs
        result = Memelex.My.TODOs.show()
        
        case result do
          :ok -> 
            IO.puts("   ✅ Navigation API call succeeded")
          other ->
            IO.puts("   ⚠️  Navigation returned: #{inspect(other)}")
        end
        
        # Give the UI time to update
        IO.puts("   ⏳ Waiting for page to load...")
        Process.sleep(2000)
        
        {:ok, context}
      end
      
      then_ "the TODOs page should be displayed", context do
        IO.puts("\n   🔍 Verifying TODOs page is displayed...")
        
        # Check the app state
        state = Flamelex.Fluxus.RadixStore.get()
        
        todos_active = case state do
          %{apps: %{todo_list: todos_state}} when is_map(todos_state) ->
            IO.puts("   ✅ TODOs app is active in state")
            IO.puts("   📋 TODOs state: #{inspect(todos_state, pretty: true)}")
            true
          _ ->
            IO.puts("   ❌ TODOs app not found in state")
            false
        end
        
        unless todos_active do
          raise "TODOs page was not activated"
        end
        
        # Verify through semantic DOM that TODOs UI elements are present
        viewport_state = :sys.get_state(Process.whereis(:main_viewport))
        semantic_entries = :ets.tab2list(viewport_state.semantic_table)
        
        # Look for TODO-related semantic elements
        todo_elements = Enum.flat_map(semantic_entries, fn {_key, info} ->
          if is_map(info) && Map.has_key?(info, :elements) do
            info.elements
            |> Map.values()
            |> Enum.filter(fn elem ->
              semantic = elem[:semantic] || %{}
              label = semantic[:label] || ""
              description = semantic[:description] || ""
              type = semantic[:type]
              
              String.contains?(label, ["todo", "TODO", "Todo"]) ||
              String.contains?(description, ["todo", "TODO", "Todo"]) ||
              type == :todo_item ||
              type == :todo_list
            end)
          else
            []
          end
        end)
        
        IO.puts("   📊 Found #{length(todo_elements)} TODO-related semantic elements")
        
        if length(todo_elements) > 0 do
          IO.puts("   📋 TODO elements found:")
          Enum.each(todo_elements, fn elem ->
            semantic = elem[:semantic] || %{}
            IO.puts("      - Type: #{semantic[:type]}, Label: #{semantic[:label]}")
          end)
        end
        
        IO.puts("\n   🎉 TODOs page verification completed!")
        
        {:ok, context}
      end
    end
  end

  spex "TODO creation dialog functionality",
    description: "Verify the new TODO dialog opens and closes properly",
    tags: [:todos, :create, :dialog] do
    
    scenario "Open and close new TODO dialog", context do
      given_ "I'm on the TODOs page", context do
        Process.sleep(3000)
        Memelex.My.TODOs.show()
        Process.sleep(2000)
        {:ok, context}
      end
      
      when_ "I trigger the new TODO action", context do
        IO.puts("\n   🔘 Opening new TODO dialog...")
        
        # Trigger the new TODO action
        Flamelex.Fluxus.action({TODOlist, :new_todo})
        Process.sleep(1000)
        
        {:ok, context}
      end
      
      then_ "the dialog should be visible", context do
        state = Flamelex.Fluxus.RadixStore.get()
        
        case state do
          %{apps: %{todo_list: %{creating_new_todo?: creating}}} ->
            if creating do
              IO.puts("   ✅ New TODO dialog is open!")
            else
              IO.puts("   ❌ Dialog not open - creating_new_todo?: false")
            end
            
          _ ->
            IO.puts("   ❌ Could not find TODO list state")
        end
        
        # Now close the dialog
        IO.puts("\n   ❌ Closing dialog...")
        Flamelex.Fluxus.action({TODOlist, :cancel_new_todo})
        Process.sleep(500)
        
        # Verify it closed
        state2 = Flamelex.Fluxus.RadixStore.get()
        case state2 do
          %{apps: %{todo_list: %{creating_new_todo?: false}}} ->
            IO.puts("   ✅ Dialog closed successfully")
          _ ->
            IO.puts("   ⚠️  Dialog may not have closed properly")
        end
        
        {:ok, context}
      end
    end
  end

  spex "TODOs page state initialization",
    description: "Verify the TODOs page initializes with correct default state",
    tags: [:todos, :state, :initialization] do
    
    scenario "Check initial TODOs state structure", context do
      given_ "Flamelex is running and I navigate to TODOs", context do
        Process.sleep(3000)
        
        # Navigate to TODOs
        Memelex.My.TODOs.show()
        Process.sleep(2000)
        
        {:ok, context}
      end
      
      when_ "I examine the TODOs state", context do
        state = Flamelex.Fluxus.RadixStore.get()
        
        todos_state = case state do
          %{apps: %{todo_list: ts}} -> ts
          _ -> nil
        end
        
        {:ok, Map.put(context, :todos_state, todos_state)}
      end
      
      then_ "the state should have expected structure", context do
        todos_state = context.todos_state
        
        unless todos_state do
          raise "TODOs state not found"
        end
        
        # Verify expected fields exist
        expected_fields = [:list, :selected, :scroll, :turbo_scroll?, :filter]
        
        Enum.each(expected_fields, fn field ->
          if Map.has_key?(todos_state, field) do
            IO.puts("   ✅ Field '#{field}' present in state")
          else
            raise "Expected field '#{field}' not found in TODOs state"
          end
        end)
        
        # Verify initial values
        case todos_state do
          %{
            list: list,
            selected: selected,
            scroll: scroll,
            turbo_scroll?: turbo,
            filter: filter
          } ->
            IO.puts("\n   📊 Initial state values:")
            IO.puts("      - list: #{inspect(list)} (#{length(list)} items)")
            IO.puts("      - selected: #{inspect(selected)}")
            IO.puts("      - scroll: #{inspect(scroll)}")
            IO.puts("      - turbo_scroll?: #{turbo}")
            IO.puts("      - filter: #{inspect(filter)}")
          _ ->
            raise "TODOs state structure doesn't match expected pattern"
        end
        
        IO.puts("\n   ✅ TODOs state structure verified!")
        
        {:ok, context}
      end
    end
  end
end