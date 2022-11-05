defmodule Flamelex.Keymaps.Editor.GlobalBindings do

   defmacro __using__(_opts) do
      quote do

         @leader :key_space

      end
   end
end