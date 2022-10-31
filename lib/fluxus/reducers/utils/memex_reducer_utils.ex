defmodule Flamelex.Fluxus.Reducers.Memex.Utils do

    # def edit_tidbit do
    #     new_open_tidbits_list =
    #     radix_state.memex.story_river.open_tidbits
    #     |> Enum.map(fn 
    #             %{uuid: ^tidbit_uuid} = tidbit ->
    #                 tidbit |> Map.merge(%{mode: :edit, cursor: String.length(tidbit.data)})
    #             other_tidbit ->
    #                 other_tidbit
    #             end)

    #     new_radix_state = radix_state
    #     |> put_in([:memex, :story_river, :open_tidbits], new_open_tidbits_list)
    # end
end