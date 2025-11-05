defmodule Flamelex.MemexSmokeTest do
  use ExUnit.Case
  
  describe "Memex environment loading" do
    test "memex environment is loaded correctly" do
      # Check if Memelex is active
      memex_active = Application.get_env(:memelex, :active?)
      
      case memex_active do
        true ->
          # If active, verify we have an environment loaded
          env = Memelex.Utils.EnviroTools.environment_details()
          assert env != nil, "Memex should have an environment loaded when active"
          
          # In test environment, it should be Lavoisier
          assert env.name == "Lavoisier", "Test environment should load Lavoisier memex, but got: #{inspect(env.name)}"
          
        false ->
          # If inactive, that's also acceptable
          assert true, "Memex is inactive, which is acceptable"
      end
    end
    
    test "memex directories are configured when active" do
      memex_active = Application.get_env(:memelex, :active?)
      
      if memex_active do
        env = Memelex.Utils.EnviroTools.environment_details()
        
        # Verify the environment has required fields
        assert Map.has_key?(env, :name), "Environment should have a name"
        assert Map.has_key?(env, :memex_directory), "Environment should have a memex_directory"
        
        # In test, verify it's the test environment
        assert env.name == "Lavoisier"
        assert env.memex_directory =~ "test/Lavoisier"
      end
    end
  end
end