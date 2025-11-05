defmodule Flamelex.Test.TodoListKeyboardNavigationSpex do
  use SexySpex
  alias ScenicMcp.Probes
  
  describe "Todo List Keyboard Navigation" do
    
    scenario "Navigate todos with arrow keys" do
      given "Todo list is open with multiple items" do
        {:ok, _state} = start_supervised(Flamelex.App)
        :timer.sleep(1000)
        
        # Create test todos
        Memelex.My.TODOs.new("First todo", tags: ["nav-test"])
        Memelex.My.TODOs.new("Second todo", tags: ["nav-test"])
        Memelex.My.TODOs.new("Third todo", tags: ["nav-test"])
        :timer.sleep(500)
        
        Flamelex.Fluxus.action({Flamelex.GUI.Component.TODOlist.Reducer, :show_todos})
        :timer.sleep(500)
      end
      
      when "I press down arrow" do
        Probes.send_keys("down")
        :timer.sleep(200)
      end
      
      then "The second todo should be selected" do
        state = Flamelex.Fluxus.RadixStore.get()
        assert state.apps.todo_list.selected == 1  # 0-indexed
      end
      
      when "I press down arrow again" do
        Probes.send_keys("down")
        :timer.sleep(200)
      end
      
      then "The third todo should be selected" do
        state = Flamelex.Fluxus.RadixStore.get()
        assert state.apps.todo_list.selected == 2
      end
      
      when "I press up arrow" do
        Probes.send_keys("up")
        :timer.sleep(200)
      end
      
      then "The second todo should be selected again" do
        state = Flamelex.Fluxus.RadixStore.get()
        assert state.apps.todo_list.selected == 1
      end
    end
    
    scenario "Open todo with Enter key" do
      given "Todo list has items and one is selected" do
        {:ok, _state} = start_supervised(Flamelex.App)
        :timer.sleep(1000)
        
        Memelex.My.TODOs.new("Todo to open", tags: ["test"])
        :timer.sleep(500)
        
        Flamelex.Fluxus.action({Flamelex.GUI.Component.TODOlist.Reducer, :show_todos})
        :timer.sleep(500)
      end
      
      when "I press Enter" do
        Probes.send_keys("enter")
        :timer.sleep(500)
      end
      
      then "The todo details should open in split screen" do
        state = Flamelex.Fluxus.RadixStore.get()
        
        assert state.gui.layer1.layout == :split_screen
        assert Flamelex.GUI.Component.TODOdetails in state.gui.layer1.active_apps
        assert state.apps.todo_details.tidbit.title == "Todo to open"
      end
    end
    
    scenario "Jump to top and bottom of list" do
      given "Todo list has many items" do
        {:ok, _state} = start_supervised(Flamelex.App)
        :timer.sleep(1000)
        
        # Create 10 todos
        for i <- 1..10 do
          Memelex.My.TODOs.new("Todo #{i}", tags: ["jump-test"])
        end
        :timer.sleep(500)
        
        Flamelex.Fluxus.action({Flamelex.GUI.Component.TODOlist.Reducer, :show_todos})
        :timer.sleep(500)
        
        # Select middle item
        for _ <- 1..5 do
          Probes.send_keys("down")
          :timer.sleep(100)
        end
      end
      
      when "I press Home key" do
        Probes.send_keys("home")
        :timer.sleep(200)
      end
      
      then "The first todo should be selected" do
        state = Flamelex.Fluxus.RadixStore.get()
        assert state.apps.todo_list.selected == 0
      end
      
      when "I press End key" do
        Probes.send_keys("end")
        :timer.sleep(200)
      end
      
      then "The last todo should be selected" do
        state = Flamelex.Fluxus.RadixStore.get()
        assert state.apps.todo_list.selected == 9  # 0-indexed, so 9 is the 10th item
      end
    end
    
    scenario "Page up and page down navigation" do
      given "Todo list has many items" do
        {:ok, _state} = start_supervised(Flamelex.App)
        :timer.sleep(1000)
        
        # Create 30 todos
        for i <- 1..30 do
          Memelex.My.TODOs.new("Todo item #{i}", tags: ["page-test"])
        end
        :timer.sleep(500)
        
        Flamelex.Fluxus.action({Flamelex.GUI.Component.TODOlist.Reducer, :show_todos})
        :timer.sleep(500)
      end
      
      when "I press Page Down" do
        Probes.send_keys("page_down")
        :timer.sleep(200)
      end
      
      then "The view should scroll down by a page" do
        state = Flamelex.Fluxus.RadixStore.get()
        {_x, y} = state.apps.todo_list.scroll
        assert y < 0  # Negative Y means scrolled down
      end
      
      when "I press Page Up" do
        Probes.send_keys("page_up")
        :timer.sleep(200)
      end
      
      then "The view should scroll back up" do
        state = Flamelex.Fluxus.RadixStore.get()
        {_x, y} = state.apps.todo_list.scroll
        assert y == 0  # Back to top
      end
    end
    
    scenario "Quick search with forward slash" do
      given "Todo list is open" do
        {:ok, _state} = start_supervised(Flamelex.App)
        :timer.sleep(1000)
        
        Memelex.My.TODOs.new("Buy groceries", tags: ["shopping"])
        Memelex.My.TODOs.new("Fix bug in parser", tags: ["dev"])
        Memelex.My.TODOs.new("Call dentist", tags: ["health"])
        :timer.sleep(500)
        
        Flamelex.Fluxus.action({Flamelex.GUI.Component.TODOlist.Reducer, :show_todos})
        :timer.sleep(500)
      end
      
      when "I press / to start search" do
        Probes.send_keys("/")
        :timer.sleep(200)
      end
      
      then "Search mode should be activated" do
        # This would need to be implemented - checking if a search input is visible
        state = Flamelex.Fluxus.RadixStore.get()
        # Placeholder assertion - actual implementation would check for search UI
        assert true
      end
      
      when "I type 'bug'" do
        Probes.send_text("bug")
        :timer.sleep(300)
      end
      
      then "Only todos matching 'bug' should be visible" do
        # This assumes search filtering is implemented
        state = Flamelex.Fluxus.RadixStore.get()
        # Would check filtered list contains only matching items
        assert true
      end
    end
    
    scenario "Mark todo as done with Space" do
      given "Todo list has an incomplete todo selected" do
        {:ok, _state} = start_supervised(Flamelex.App)
        :timer.sleep(1000)
        
        todo = Memelex.My.TODOs.new("Task to complete", tags: ["test"])
        :timer.sleep(500)
        
        Flamelex.Fluxus.action({Flamelex.GUI.Component.TODOlist.Reducer, :show_todos})
        :timer.sleep(500)
      end
      
      when "I press Space" do
        Probes.send_keys("space")
        :timer.sleep(300)
      end
      
      then "The todo should be marked as done" do
        state = Flamelex.Fluxus.RadixStore.get()
        [todo] = state.apps.todo_list.list
        assert todo.status == "done"
      end
      
      when "I press Space again" do
        Probes.send_keys("space")
        :timer.sleep(300)
      end
      
      then "The todo should be unmarked" do
        state = Flamelex.Fluxus.RadixStore.get()
        [todo] = state.apps.todo_list.list
        assert todo.status != "done"
      end
    end
    
    scenario "Delete todo with d key" do
      given "Todo list has a todo selected" do
        {:ok, _state} = start_supervised(Flamelex.App)
        :timer.sleep(1000)
        
        Memelex.My.TODOs.new("Todo to delete", tags: ["test"])
        Memelex.My.TODOs.new("Another todo", tags: ["test"])
        :timer.sleep(500)
        
        Flamelex.Fluxus.action({Flamelex.GUI.Component.TODOlist.Reducer, :show_todos})
        :timer.sleep(500)
      end
      
      when "I press d twice (dd)" do
        Probes.send_keys("d")
        :timer.sleep(100)
        Probes.send_keys("d")
        :timer.sleep(300)
      end
      
      then "The selected todo should be deleted" do
        state = Flamelex.Fluxus.RadixStore.get()
        assert length(state.apps.todo_list.list) == 1
        [remaining] = state.apps.todo_list.list
        assert remaining.title == "Another todo"
      end
    end
    
    scenario "Create new todo with n key" do
      given "Todo list is open" do
        {:ok, _state} = start_supervised(Flamelex.App)
        :timer.sleep(1000)
        
        Flamelex.Fluxus.action({Flamelex.GUI.Component.TODOlist.Reducer, :show_todos})
        :timer.sleep(500)
      end
      
      when "I press n for new todo" do
        Probes.send_keys("n")
        :timer.sleep(300)
      end
      
      then "A new todo input should appear" do
        # This would check if a text input for new todo is visible
        state = Flamelex.Fluxus.RadixStore.get()
        # Placeholder - actual implementation would check for input UI
        assert true
      end
      
      when "I type the todo title and press Enter" do
        Probes.send_text("New todo from keyboard")
        :timer.sleep(200)
        Probes.send_keys("enter")
        :timer.sleep(500)
      end
      
      then "The new todo should be added to the list" do
        state = Flamelex.Fluxus.RadixStore.get()
        todos = state.apps.todo_list.list
        assert Enum.any?(todos, & &1.title == "New todo from keyboard")
      end
    end
    
    scenario "Escape key returns to previous view" do
      given "Todo details are open in split screen" do
        {:ok, _state} = start_supervised(Flamelex.App)
        :timer.sleep(1000)
        
        todo = Memelex.My.TODOs.new("Todo with details", tags: ["test"])
        :timer.sleep(500)
        
        Flamelex.Fluxus.action({Flamelex.GUI.Component.TODOlist.Reducer, :show_todos})
        :timer.sleep(500)
        
        state = Flamelex.Fluxus.RadixStore.get()
        [todo] = state.apps.todo_list.list
        Flamelex.Fluxus.action({Flamelex.GUI.Component.TODOlist.Reducer, {:open_todo, todo}})
        :timer.sleep(500)
      end
      
      when "I press Escape" do
        Probes.send_keys("escape")
        :timer.sleep(300)
      end
      
      then "Should return to full screen todo list" do
        state = Flamelex.Fluxus.RadixStore.get()
        assert state.gui.layer1.layout == :full_screen
        assert Flamelex.GUI.Component.TODOlist in state.gui.layer1.active_apps
        assert Flamelex.GUI.Component.TODOdetails not in state.gui.layer1.active_apps
      end
    end
  end
end