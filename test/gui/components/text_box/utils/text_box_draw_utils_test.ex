defmodule Flamelex.Test.GUI.Components.TextBox.Utils.TextBoxDrawUtilsTest do
  use ExUnit.Case
  alias Flamelex.GUI.Component.Utils.TextBox, as: TextBoxDrawUtils
  alias Flamelex.GUI.Utils.Draw

  @test_quote "Manufacturing is more than just putting parts together. Testing leads to failure, and failure leads to understanding."

  test "`re_render_lines/2` returns a %Scenic.Graph{} with an updated :text_body" do

    new_graph =
      Scenic.Graph.build()
      |> Scenic.Primitives.text("blank", id: :text_body) # this function calls modify, so, the text already needs to be there...
      |> TextBoxDrawUtils.re_render_lines(%{lines: [%{line: 1, text: @test_quote}]})

    first_primitive = new_graph.primitives[1]

    assert first_primitive.id     == :text_body
    assert first_primitive.module == Scenic.Primitive.Text
    assert first_primitive.data   == @test_quote <> "\n"
  end
end
