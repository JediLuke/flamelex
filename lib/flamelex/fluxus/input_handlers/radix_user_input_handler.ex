defmodule Flamelex.Fluxus.RadixUserInputHandler do
    @moduledoc """

    """
    require Logger
  
    def handle(%{root: %{mode: :kommand}} = radix_state, input) do
        #   {:error, "RadixUserInputHandler bottomed-out! No match was found."}
        IO.puts "KOMMAND KOMMAND"
            :ignore
        end
  
  
    def handle(radix_state, input) do
    #   {:error, "RadixUserInputHandler bottomed-out! No match was found."}
        Logger.debug "Handling... #{inspect input}"
        :ignore
    end
  
  end
  