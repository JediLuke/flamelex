# def render_tags(graph, %{tags: []}, _offset) do
#     graph
# end

# def render_tags(graph, %{tags: [tag|rest]}, offset \\ 0) do
#     tag_width  = 70
#     tag_height = 20
#     tag_color  = :red
#     tag_translation = {@opts.margin+(offset*tag_width), @opts.margin}

#     graph
#     |> Scenic.Primitives.group( # render a single tag
#             fn graph ->
#                 graph
#                 |> Scenic.Primitives.rounded_rectangle({tag_width, tag_height, 8}, fill: tag_color)
#                 |> Scenic.Primitives.text(tag,
#                     font: :ibm_plex_mono,
#                     translate: {10, 15}, # text draws from bottom-left corner??
#                     font_size: 14,
#                     fill: :black)
#             end,
#             translate: tag_translation)
#     |> render_tags(%{tags: rest}, offset+1) #NOTE: This is a recursive call...
# end