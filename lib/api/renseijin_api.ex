defmodule Flamelex.API.Renseijin do
   @moduledoc """
   “Give me today, for once, the worst throw of your dice, destiny.
   Today I transmute everything into gold.”

   — Friedrich Nietzsche
   """

   def start_animation do

      # NOTE - this is one of the few components which we go around the
      # Fluxus system, and just send it messages directly, because it is
      # unaffected by any other state in the application.
      Flamelex.GUI.Component.Renseijin
      |> GenServer.cast(:start_animation)

      IO.puts "~~ Double, double toil and trouble; Fire burn and cauldron bubble ~~"

      :ok
   end

   def stop_animation do
      Flamelex.GUI.Component.Renseijin
      |> GenServer.cast(:stop_animation)
   end

   # def kaomoji do
   #   "☆*:.｡.o(≧▽≦)o.｡.:*☆"
   # end

end