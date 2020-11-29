defmodule Flamelex.Test.Buffers.BufferTest do
  use ExUnit.Case

  alias Flamelex.API.Buffer


  @content_a "“This is why alchemy exists,\" the boy said. \"So that everyone will search for his treasure, find it, and then want to be better than he was in his former life. Lead will play its role until the world has no further need for lead; and then lead will have to turn itself into gold... "
  @content_b "That's what alchemists do. They show that, when we strive to become better than we are, everything around us becomes better, too.” ― Paulo Coelho, The Alchemist"



  setup_all do
    test_file = File.cwd! <> "/test/sample_data/quotes.txt"

    # write to this file (create if not already exist) and white some known
    # contents to it, so that we can test if the Buffer is working correctly
    {:ok, file} = File.open test_file, [:write]
    IO.binwrite(file, @content_a <> @content_b)
    File.close file

    %{test_file: test_file}

  end


  test "the basic functionality of the API", %{test_file: test_file} do

    #ASSUMPTION!: no Buffers are open at the start of the test
    assert Buffer.list == []

    original_file_data = File.read!(test_file)

    b = Buffer.open! test_file

    assert Buffer.list == [b] # the Buffer.list now contains the buffer we just opened

    contents = Buffer.read b

    assert contents == @content_a <> @content_b
    assert contents == original_file_data

    :ok = b |> Buffer.modify({:insert, "Luke is the best! ", String.length(@content_a)})

    contents_after_modify = Buffer.read b # read it again to get the update...

    assert contents_after_modify ==
             @content_a <> "Luke is the best! " <> @content_b

    Buffer.save b

    assert Flamelex.BufferManager.count_open_buffers == 1

    Buffer.close b

    assert File.read!(test_file) != original_file_data # check the contents on disk have been modified

    assert Flamelex.BufferManager.count_open_buffers == 0
    assert Buffer.list == []
    assert Flamelex.Buffer.Supervisor
           |> DynamicSupervisor.count_children() == %{
                active: 0, specs: 0, supervisors: 0, workers: 0}

  end
end
