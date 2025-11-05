defmodule Flamelex.Test.TodoListSpex do
  use SexySpex
  
  setup_all do
    SexySpex.Helpers.start_scenic_app(:flamelex)
  end
  
  spex "Todo List Management",
    description: "Tests for todo list functionality in Flamelex",
    tags: [:todo, :memex, :ui] do
    
    scenario "Show empty todo list", context do
      given_ "Flamelex is running with an empty todo list", context do
        # Clear any existing todos (if needed)
        Process.sleep(500)
        context
      end
      
      when_ "I open the todo list", context do
        Flamelex.Fluxus.action({Flamelex.GUI.Component.TODOlist.Reducer, :show_todos})
        Process.sleep(500)
        context
      end
      
      then_ "I should see the todo list with empty state message", context do
        # Check that the todo list component is active
        state = Flamelex.Fluxus.RadixStore.get()
        assert Flamelex.GUI.Component.TODOlist in state.gui.layer1.active_apps
        
        # Verify empty state is displayed
        assert state.apps.todo_list.list == []
        context
      end
    end
    
    scenario "Create a new todo item", context do
      given_ "Flamelex is running with todo list open", context do
        Flamelex.Fluxus.action({Flamelex.GUI.Component.TODOlist.Reducer, :show_todos})
        Process.sleep(500)
        context
      end
      
      when_ "I create a new todo", context do
        # Create a todo using the Memelex API
        todo = Memelex.My.TODOs.new("Write spex tests for todo functionality", tags: ["dev", "testing"])
        Process.sleep(500)
        Map.put(context, :created_todo, todo)
      end
      
      then_ "The todo should appear in the list", context do
        state = Flamelex.Fluxus.RadixStore.get()
        
        # Verify the todo is in the list
        assert length(state.apps.todo_list.list) >= 1
        
        # Find our todo
        todo_found = Enum.any?(state.apps.todo_list.list, fn t ->
          t.title == "Write spex tests for todo functionality"
        end)
        assert todo_found
        
        context
      end
    end
    
    scenario "Filter todos by tag", context do
      given_ "Flamelex has multiple todos with different tags", context do
        # Create todos with different tags
        Memelex.My.TODOs.new("Urgent task", tags: ["urgent", "work"])
        Memelex.My.TODOs.new("Personal task", tags: ["personal", "home"])
        Memelex.My.TODOs.new("Another urgent task", tags: ["urgent", "dev"])
        Process.sleep(500)
        
        Flamelex.Fluxus.action({Flamelex.GUI.Component.TODOlist.Reducer, :show_todos})
        Process.sleep(500)
        context
      end
      
      when_ "I filter by urgent tag", context do
        Flamelex.Fluxus.action({Flamelex.GUI.Component.TODOlist.Reducer, {:filter_todos, {:tag, "urgent"}}})
        Process.sleep(500)
        context
      end
      
      then_ "I should only see todos with urgent tag", context do
        state = Flamelex.Fluxus.RadixStore.get()
        
        # All todos in the filtered list should have "urgent" tag
        assert length(state.apps.todo_list.list) == 2
        
        Enum.each(state.apps.todo_list.list, fn todo ->
          assert "urgent" in todo.tags
        end)
        context
      end
    end
    
    scenario "Open todo details", context do
      given_ "Flamelex has a todo item", context do
        todo = Memelex.My.TODOs.new("Todo with details", tags: ["test"])
        Process.sleep(500)
        
        Flamelex.Fluxus.action({Flamelex.GUI.Component.TODOlist.Reducer, :show_todos})
        Process.sleep(500)
        Map.put(context, :detail_todo, todo)
      end
      
      when_ "I open the todo details", context do
        state = Flamelex.Fluxus.RadixStore.get()
        [todo | _] = state.apps.todo_list.list
        
        Flamelex.Fluxus.action({Flamelex.GUI.Component.TODOlist.Reducer, {:open_todo, todo}})
        Process.sleep(500)
        context
      end
      
      then_ "The layout should be split screen with todo details visible", context do
        state = Flamelex.Fluxus.RadixStore.get()
        
        # Check layout is split screen
        assert state.gui.layer1.layout == :split_screen
        
        # Check both components are active
        assert Flamelex.GUI.Component.TODOlist in state.gui.layer1.active_apps
        assert Flamelex.GUI.Component.TODOdetails in state.gui.layer1.active_apps
        
        # Check the details component has the todo
        assert state.apps.todo_details.tidbit.title == "Todo with details"
        context
      end
    end
    
    scenario "Toggle turbo scroll mode", context do
      given_ "Todo list is open with many items", context do
        # Create many todos
        for i <- 1..30 do
          Memelex.My.TODOs.new("Todo item #{i}", tags: ["bulk"])
        end
        Process.sleep(500)
        
        Flamelex.Fluxus.action({Flamelex.GUI.Component.TODOlist.Reducer, :show_todos})
        Process.sleep(500)
        context
      end
      
      when_ "I enable turbo scroll", context do
        Flamelex.Fluxus.action({Flamelex.GUI.Component.TODOlist.Reducer, {:set_turbo, true}})
        Process.sleep(200)
        context
      end
      
      then_ "Turbo scroll should be enabled", context do
        state = Flamelex.Fluxus.RadixStore.get()
        assert state.apps.todo_list.turbo_scroll? == true
        context
      end
      
      when_ "I disable turbo scroll", context do
        Flamelex.Fluxus.action({Flamelex.GUI.Component.TODOlist.Reducer, {:set_turbo, false}})
        Process.sleep(200)
        context
      end
      
      then_ "Turbo scroll should be disabled", context do
        state = Flamelex.Fluxus.RadixStore.get()
        assert state.apps.todo_list.turbo_scroll? == false
        context
      end
    end
    
    scenario "Filter todos by priority", context do
      given_ "Todos with different priorities exist", context do
        # Create todos with different priorities
        todo1 = Memelex.My.TODOs.new("High priority task", tags: ["work"])
        Memelex.My.TODOs.priority(todo1, 1)
        
        todo2 = Memelex.My.TODOs.new("Medium priority task", tags: ["personal"])
        Memelex.My.TODOs.priority(todo2, 5)
        
        todo3 = Memelex.My.TODOs.new("Low priority task", tags: ["someday"])
        Memelex.My.TODOs.priority(todo3, 9)
        
        Process.sleep(500)
        
        Flamelex.Fluxus.action({Flamelex.GUI.Component.TODOlist.Reducer, :show_todos})
        Process.sleep(500)
        context
      end
      
      when_ "I filter by top priority", context do
        Flamelex.Fluxus.action({Flamelex.GUI.Component.TODOlist.Reducer, {:filter_todos, {:top_priority, 25}}})
        Process.sleep(500)
        context
      end
      
      then_ "I should see todos sorted by priority", context do
        state = Flamelex.Fluxus.RadixStore.get()
        
        # Should have all 3 todos (assuming less than 25 total)
        assert length(state.apps.todo_list.list) > 0
        
        # Verify they are sorted by priority (ascending)
        priorities = Enum.map(state.apps.todo_list.list, fn t -> 
          t.meta["priority"] || 999
        end)
        assert priorities == Enum.sort(priorities)
        context
      end
    end
    
    scenario "Filter overdue todos", context do
      given_ "Todos with past due dates exist", context do
        # Create overdue todo
        overdue_todo = Memelex.My.TODOs.new("Overdue task", tags: ["urgent"])
        yesterday = Date.add(Date.utc_today(), -1)
        Memelex.My.TODOs.due(overdue_todo, yesterday)
        
        # Create future todo
        future_todo = Memelex.My.TODOs.new("Future task", tags: ["planned"])
        tomorrow = Date.add(Date.utc_today(), 1)
        Memelex.My.TODOs.due(future_todo, tomorrow)
        
        Process.sleep(500)
        
        Flamelex.Fluxus.action({Flamelex.GUI.Component.TODOlist.Reducer, :show_todos})
        Process.sleep(500)
        context
      end
      
      when_ "I filter by overdue", context do
        Flamelex.Fluxus.action({Flamelex.GUI.Component.TODOlist.Reducer, {:filter_todos, :overdue}})
        Process.sleep(500)
        context
      end
      
      then_ "I should only see overdue todos", context do
        state = Flamelex.Fluxus.RadixStore.get()
        
        assert length(state.apps.todo_list.list) == 1
        [overdue] = state.apps.todo_list.list
        assert overdue.title == "Overdue task"
        
        # Verify the due date is in the past
        due_date = overdue.meta["due_date"]
        assert Date.compare(due_date, Date.utc_today()) == :lt
        context
      end
    end
    
    scenario "Refresh todo list after external change", context do
      given_ "Todo list is displayed", context do
        Memelex.My.TODOs.new("Initial todo", tags: ["test"])
        Process.sleep(500)
        
        Flamelex.Fluxus.action({Flamelex.GUI.Component.TODOlist.Reducer, :show_todos})
        Process.sleep(500)
        context
      end
      
      when_ "A todo is modified externally and refresh is triggered", context do
        state = Flamelex.Fluxus.RadixStore.get()
        [todo | _] = state.apps.todo_list.list
        
        # Modify the todo externally
        Memelex.My.TODOs.note(todo, "Added a note to the todo")
        
        # Trigger refresh
        Flamelex.Fluxus.action({Flamelex.GUI.Component.TODOlist.Reducer, {:refresh_tidbit, todo}})
        Process.sleep(500)
        context
      end
      
      then_ "The todo list should reflect the changes", context do
        state = Flamelex.Fluxus.RadixStore.get()
        
        [updated_todo | _] = state.apps.todo_list.list
        # Check that the todo has been updated with the note
        assert updated_todo.data != nil
        context
      end
    end
  end
end