defmodule Flamelex.Test.TodoMemexIntegrationSpex do
  use SexySpex
  
  describe "Todo and Memex Integration" do
    
    scenario "Link todo to wiki page" do
      given "A todo and a wiki page exist" do
        {:ok, _state} = start_supervised(Flamelex.App)
        :timer.sleep(1000)
        
        # Create a wiki page
        wiki_page = Memelex.My.Wiki.new("Project Documentation", 
          tags: ["docs", "project"],
          data: "This page contains all project documentation..."
        )
        
        # Create a todo
        todo = Memelex.My.TODOs.new("Review project documentation", 
          tags: ["review", "docs"]
        )
        :timer.sleep(500)
      end
      
      when "I link the todo to the wiki page" do
        Memelex.My.Wiki.link(todo, wiki_page)
        :timer.sleep(300)
      end
      
      then "The todo should have a link to the wiki page" do
        # Refresh the todo from storage
        updated_todo = Memelex.find(todo.uuid)
        
        assert length(updated_todo.links) == 1
        [link] = updated_todo.links
        assert link.uuid == wiki_page.uuid
      end
      
      and_also "The wiki page should have a backlink to the todo" do
        updated_wiki = Memelex.find(wiki_page.uuid)
        
        assert length(updated_wiki.backlinks) == 1
        [backlink] = updated_wiki.backlinks
        assert backlink.uuid == todo.uuid
      end
    end
    
    scenario "Convert todo to journal entry when completed" do
      given "A completed todo exists" do
        {:ok, _state} = start_supervised(Flamelex.App)
        :timer.sleep(1000)
        
        todo = Memelex.My.TODOs.new("Finish quarterly report", tags: ["work", "reports"])
        Memelex.My.TODOs.done(todo)
        :timer.sleep(500)
      end
      
      when "I convert the todo to a journal entry" do
        # This would be a new feature - converting completed todos to journal entries
        journal_entry = Memelex.My.Journal.from_todo(todo)
        :timer.sleep(300)
      end
      
      then "A journal entry should be created with todo information" do
        assert journal_entry.title =~ "Completed: Finish quarterly report"
        assert journal_entry.type == "journal"
        assert "completed_todo" in journal_entry.tags
        assert journal_entry.data =~ todo.uuid  # Reference to original todo
      end
    end
    
    scenario "Create todo from highlighted text in a document" do
      given "A document is open with text selected" do
        {:ok, _state} = start_supervised(Flamelex.App)
        :timer.sleep(1000)
        
        # Create a document
        doc = Memelex.My.Wiki.new("Meeting Notes", 
          data: "Action items:\n- Follow up with client about proposal\n- Update project timeline\n- Schedule team review"
        )
        
        # Simulate having text selected (this would come from the editor)
        selected_text = "Follow up with client about proposal"
        :timer.sleep(500)
      end
      
      when "I create a todo from the selected text" do
        # This would be triggered by a keyboard shortcut
        todo = Memelex.My.TODOs.from_selection(selected_text, source: doc)
        :timer.sleep(300)
      end
      
      then "A todo should be created with the selected text as title" do
        assert todo.title == "Follow up with client about proposal"
        assert todo.type == "todo"
      end
      
      and_also "The todo should be linked to the source document" do
        assert length(todo.links) == 1
        [link] = todo.links
        assert link.uuid == doc.uuid
      end
    end
    
    scenario "Tag inheritance from parent tidbit" do
      given "A project tidbit with todos as children" do
        {:ok, _state} = start_supervised(Flamelex.App)
        :timer.sleep(1000)
        
        # Create a project
        project = Memelex.My.Wiki.new("Website Redesign Project", 
          tags: ["project", "web", "q4-2024"]
        )
        
        # Create todos as children of the project
        todo1 = Memelex.My.TODOs.new("Design new homepage", parent: project)
        todo2 = Memelex.My.TODOs.new("Update color scheme", parent: project)
        :timer.sleep(500)
      end
      
      when "I view the todos" do
        # Todos should inherit certain tags from parent
        :timer.sleep(200)
      end
      
      then "Todos should inherit project tags" do
        # Check that todos have inherited the project tag
        assert "project" in todo1.tags
        assert "web" in todo1.tags
        assert "project" in todo2.tags
        assert "web" in todo2.tags
      end
    end
    
    scenario "Todo templates from memex" do
      given "A todo template exists in the memex" do
        {:ok, _state} = start_supervised(Flamelex.App)
        :timer.sleep(1000)
        
        # Create a template
        template = Memelex.My.Wiki.new("Code Review Template", 
          tags: ["template", "todo-template", "dev"],
          data: """
          - [ ] Check code style and formatting
          - [ ] Verify test coverage
          - [ ] Review documentation
          - [ ] Check for security issues
          - [ ] Verify performance impact
          """
        )
        :timer.sleep(500)
      end
      
      when "I create a todo from the template" do
        todo = Memelex.My.TODOs.from_template(template, 
          title: "Review PR #123",
          tags: ["review", "pr-123"]
        )
        :timer.sleep(300)
      end
      
      then "A todo should be created with subtasks from template" do
        assert todo.title == "Review PR #123"
        assert todo.data =~ "Check code style"
        assert todo.data =~ "Verify test coverage"
        assert "review" in todo.tags
        assert "pr-123" in todo.tags
      end
      
      and_also "The todo should reference the template" do
        assert Enum.any?(todo.links, & &1.uuid == template.uuid)
      end
    end
    
    scenario "Search todos through memex rapid selector" do
      given "Multiple todos exist with different contexts" do
        {:ok, _state} = start_supervised(Flamelex.App)
        :timer.sleep(1000)
        
        # Create todos in different contexts
        Memelex.My.TODOs.new("Fix login bug", tags: ["bug", "urgent", "auth"])
        Memelex.My.TODOs.new("Add user profile feature", tags: ["feature", "user"])
        Memelex.My.TODOs.new("Update API documentation", tags: ["docs", "api"])
        Memelex.My.TODOs.new("Fix payment processing bug", tags: ["bug", "payment", "urgent"])
        :timer.sleep(500)
      end
      
      when "I search for 'bug' in rapid selector" do
        # Open rapid selector
        Flamelex.Fluxus.action({Flamelex.GUI.RapidSelector.Reducer, :show})
        :timer.sleep(300)
        
        # Type search query
        ScenicMcp.Probes.send_text("bug")
        :timer.sleep(300)
      end
      
      then "Only todos containing 'bug' should be shown" do
        state = Flamelex.Fluxus.RadixStore.get()
        
        # Check rapid selector results
        results = state.apps.rapid_selector.results
        assert length(results) == 2
        
        Enum.each(results, fn result ->
          assert result.title =~ "bug" or "bug" in result.tags
        end)
      end
    end
    
    scenario "Create todo with automatic context detection" do
      given "I'm viewing a code file with a TODO comment" do
        {:ok, _state} = start_supervised(Flamelex.App)
        :timer.sleep(1000)
        
        # Simulate having a code file open
        current_file = "/path/to/project/auth_controller.ex"
        current_line = 42
        todo_comment = "TODO: Add rate limiting to login endpoint"
        :timer.sleep(500)
      end
      
      when "I create a todo from the TODO comment" do
        todo = Memelex.My.TODOs.from_code_comment(
          todo_comment,
          file: current_file,
          line: current_line
        )
        :timer.sleep(300)
      end
      
      then "The todo should include file context" do
        assert todo.title == "Add rate limiting to login endpoint"
        assert todo.data =~ current_file
        assert todo.data =~ "Line #{current_line}"
        assert "code-todo" in todo.tags
        assert "auth_controller" in todo.tags  # Extracted from filename
      end
    end
    
    scenario "Todo collections and smart lists" do
      given "Todos exist across different projects" do
        {:ok, _state} = start_supervised(Flamelex.App)
        :timer.sleep(1000)
        
        # Create todos for different projects
        Memelex.My.TODOs.new("Frontend: Update navigation", tags: ["frontend", "project-a"])
        Memelex.My.TODOs.new("Backend: Add caching", tags: ["backend", "project-a"]) 
        Memelex.My.TODOs.new("Frontend: Fix responsive layout", tags: ["frontend", "project-b"])
        Memelex.My.TODOs.new("Deploy to staging", tags: ["devops", "project-a"])
        :timer.sleep(500)
      end
      
      when "I create a smart collection for frontend todos" do
        collection = Memelex.My.Collections.new(
          "Frontend Tasks",
          query: {:tag, "frontend"},
          type: :smart
        )
        :timer.sleep(300)
      end
      
      then "The collection should dynamically include all frontend todos" do
        items = Memelex.My.Collections.items(collection)
        assert length(items) == 2
        
        Enum.each(items, fn todo ->
          assert "frontend" in todo.tags
        end)
      end
      
      when "I add a new frontend todo" do
        Memelex.My.TODOs.new("Frontend: Add dark mode", tags: ["frontend", "project-c"])
        :timer.sleep(300)
      end
      
      then "The collection should automatically include the new todo" do
        items = Memelex.My.Collections.items(collection)
        assert length(items) == 3
      end
    end
  end
end