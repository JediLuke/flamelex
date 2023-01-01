defmodule Flamelex.Fluxus.Reducers.Editor do
   @moduledoc false
   use Flamelex.ProjectAliases
   require Logger


   def process(radix_state, :split_layer_one) do
      new_radix_state = radix_state
      |> put_in([:root, :layers, :one], :split)

      {:ok, new_radix_state}
   end

   def process(radix_state, :open_hexdocs) do
      new_radix_state = 
         radix_state
         |> put_in([:root, :active_app], :hexdocs)

      {:ok, new_radix_state}
   end

   def process(radix_state, :show_explorer) do
      new_radix_state = radix_state
      |> put_in([:root, :layers, :one], %{explorer: %{active?: true}})

      {:ok, new_radix_state}
   end

   def process(radix_state, :hide_explorer) do
      new_radix_state = radix_state
      |> put_in([:root, :layers, :one], %{layout: %{editor: :full_screen}})

      {:ok, new_radix_state}
   end
 
 end
   