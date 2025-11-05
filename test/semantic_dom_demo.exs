#!/usr/bin/env elixir

# Semantic DOM Demo
# This script demonstrates the enhanced inspect_viewport functionality
# showing both visual description and semantic DOM information

IO.puts("\n🎯 Semantic DOM Demo")
IO.puts("=" |> String.duplicate(50))

# Use the new consolidated semantic DOM tools
alias Flamelex.GUI.ScenicSemanticDOM

IO.puts("\n1️⃣ Querying all semantic elements...")
all_elements = ScenicSemanticDOM.get_all_semantic_elements()
IO.puts("   Found #{length(all_elements)} total elements")

IO.puts("\n2️⃣ Finding clickable elements...")
clickable = ScenicSemanticDOM.find_clickable()
IO.puts("   Found #{length(clickable)} clickable elements:")
Enum.each(clickable, fn elem ->
  semantic = elem[:semantic] || %{}
  IO.puts("   - #{semantic[:label] || semantic[:type]} (#{semantic[:description] || "no description"})")
end)

IO.puts("\n3️⃣ Finding menu items...")
menu_items = ScenicSemanticDOM.find_by_type(:menu_item)
IO.puts("   Found #{length(menu_items)} menu items")

IO.puts("\n4️⃣ Finding TODOs page element...")
todo_elements = ScenicSemanticDOM.query(%{type: :todo_list})
if length(todo_elements) > 0 do
  IO.puts("   ✅ TODOs page is active!")
  todo_elem = hd(todo_elements)
  semantic = todo_elem[:semantic] || %{}
  IO.puts("   Label: #{semantic[:label]}")
  IO.puts("   Description: #{semantic[:description]}")
  IO.puts("   State: #{inspect(semantic[:state])}")
else
  IO.puts("   ❌ TODOs page not found")
end

IO.puts("\n5️⃣ Semantic DOM Summary:")
ScenicSemanticDOM.summarize()

IO.puts("\n✅ Demo complete!")
IO.puts("\nThe inspect_viewport tool now includes all this semantic information,")
IO.puts("making it much easier for AI to understand and interact with the UI!\n")