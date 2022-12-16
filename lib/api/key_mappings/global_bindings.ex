defmodule Flamelex.Keymaps.Editor.GlobalBindings do

   defmacro __using__(_opts) do
      quote do
         
         use ScenicWidgets.ScenicEventsDefinitions

         @leader @space_bar
         @sub_leader @backslash

      end
   end
end