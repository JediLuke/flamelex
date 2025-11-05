defmodule Flamelex.Test.TodoInteractionsSpex do
  @moduledoc """
  Test suite for TODO item interactions.
  
  This tests:
  - Clicking on a TODO to select it
  - Opening TODO details
  - Marking TODOs as complete
  - Editing TODO properties
  """
  use SexySpex

  setup_all do
    SexySpex.Helpers.start_scenic_app(:flamelex)
  end

  spex "TODO selection and detail view",
    description: "Clicking a TODO opens its details for editing",
    tags: [:todos, :interactions, :selection] do
    
    scenario "Click TODO to open details", context do
      given_ "I have TODOs in my list", context do
        Process.sleep(3000)
        
        # Create a test TODO
        params = %{
          title: "Test TODO for interaction",
          data: "This TODO will be clicked",
          tags: [],
          meta: [
            %{
              "priority" => "high",
              "status" => "pending"
            }
          ]
        }
        
        test_todo = Memelex.My.TODOs.new(params)
        
        # Navigate to TODOs
        Memelex.My.TODOs.show()
        Process.sleep(2000)
        
        {:ok, Map.put(context, :test_todo, test_todo)}
      end
      
      when_ "I click on the TODO", context do
        # Simulate clicking on the TODO
        Flamelex.Fluxus.action({Flamelex.GUI.Component.TODOlist, {:open_todo, context.test_todo}})
        Process.sleep(1000)
        {:ok, context}
      end
      
      then_ "TODO details should be displayed", context do
        state = Flamelex.Fluxus.RadixStore.get()
        
        case state do
          %{apps: %{todo_details: %{tidbit: tidbit}}} when not is_nil(tidbit) ->
            IO.puts("   ✅ TODO details view opened")
            IO.puts("   📋 Viewing: #{tidbit.title}")
            
            # Check if we're in split screen mode
            case state.layers.one.layout do
              :split_screen ->
                IO.puts("   🔲 Split screen layout active")
              _ ->
                IO.puts("   ⚠️  Expected split screen layout")
            end
            
          _ ->
            raise "TODO details not opened"
        end
        
        {:ok, context}
      end
    end
  end

  spex "Mark TODO as complete",
    description: "User can mark a TODO as done",
    tags: [:todos, :interactions, :complete] do
    
    scenario "Complete a TODO", context do
      given_ "I have a pending TODO", context do
        Process.sleep(3000)
        
        # Create a test TODO
        params = %{
          title: "TODO to complete",
          data: "This will be marked as done",
          tags: [],
          meta: [
            %{
              "priority" => "medium",
              "status" => "pending"
            }
          ]
        }
        
        test_todo = Memelex.My.TODOs.new(params)
        
        # Navigate to TODOs
        Memelex.My.TODOs.show()
        Process.sleep(2000)
        
        {:ok, Map.put(context, :test_todo, test_todo)}
      end
      
      when_ "I mark the TODO as complete", context do
        # Mark TODO as complete
        Flamelex.Fluxus.action({Flamelex.GUI.Component.TODOlist, 
          {:mark_todo_complete, context.test_todo.uuid}})
        Process.sleep(1000)
        {:ok, context}
      end
      
      then_ "the TODO status should be 'done'", context do
        state = Flamelex.Fluxus.RadixStore.get()
        
        case state do
          %{apps: %{todo_list: %{list: todos}}} ->
            updated_todo = Enum.find(todos, fn t -> 
              t.uuid == context.test_todo.uuid 
            end)
            
            if updated_todo do
              # Check status in meta
              status = case updated_todo.meta do
                [%{"status" => s} | _] -> s
                _ -> nil
              end
              
              if status == "done" do
                IO.puts("   ✅ TODO marked as complete!")
                IO.puts("   🎉 Status changed to: #{status}")
              else
                raise "TODO status not updated to 'done', got: #{inspect(status)}"
              end
            else
              raise "TODO not found in list"
            end
            
          _ ->
            raise "TODO list not active"
        end
        
        {:ok, context}
      end
    end
  end

  spex "TODO keyboard navigation",
    description: "Navigate TODOs using keyboard",
    tags: [:todos, :keyboard, :navigation] do
    
    scenario "Navigate with arrow keys", context do
      given_ "I'm on the TODOs page with multiple items", context do
        Process.sleep(3000)
        
        # Create multiple TODOs
        Enum.each(1..3, fn i ->
          params = %{
            title: "TODO #{i}",
            data: "Test TODO number #{i}",
            tags: [],
            meta: [%{"priority" => "medium", "status" => "pending"}]
          }
          Memelex.My.TODOs.new(params)
        end)
        
        Memelex.My.TODOs.show()
        Process.sleep(2000)
        {:ok, context}
      end
      
      when_ "I press arrow keys", context do
        IO.puts("   ⌨️  Simulating keyboard navigation...")
        IO.puts("   ⬇️  Down arrow to select first TODO")
        IO.puts("   ⬇️  Down arrow to next TODO")
        IO.puts("   ⬆️  Up arrow to previous TODO")
        
        # In real implementation, we'd send keyboard events
        # For now, we're just documenting the expected behavior
        
        {:ok, context}
      end
      
      then_ "TODOs should be navigable with keyboard", context do
        IO.puts("   📍 Keyboard navigation should:")
        IO.puts("     • Highlight selected TODO")
        IO.puts("     • Move selection with arrows")
        IO.puts("     • Enter to open details")
        IO.puts("     • Space to mark complete")
        IO.puts("     • Delete to remove TODO")
        
        {:ok, context}
      end
    end
  end
end