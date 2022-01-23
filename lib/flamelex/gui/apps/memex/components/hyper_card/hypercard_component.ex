



#   def render(scene, %Memelex.TidBit{type: ["text"]} = t) do
#     Logger.debug "Now we're rendering an actual %Memelex.TidBit{} !!"
#     IO.inspect t, label: "TTT"

#     #NOTE - this could really, really use the concept of, I don't know,
#     #       some kind of a %Frame{} maybe...

#     ch = _card_height = 600
#     cw = __card_width = 1000

#     tl_x = _top_left_x = 300
#     tl_y = _top_left_y = 100

#     line_rule = 200 # the space from the top of the hypercard to the ruled line
#     left_margin = 60 # 560
#     top_margin  = 80 # 560

#     title_height = 60 # how much space our first title takes up

#     Scenic.Graph.build()
#     |> Scenic.Primitives.rect({cw, ch}, translate: {tl_x, tl_y}, fill: :antique_white)
#     |> Scenic.Primitives.line({{tl_x, tl_y+line_rule}, {tl_x+cw, tl_y+line_rule}}, stroke: {2, :green})
#     |> Scenic.Primitives.text(t.title,
#             font: :ibm_plex_mono,
#             translate: {tl_x+left_margin, tl_y+top_margin}, # text draws from bottom-left corner??
#             font_size: 36,
#             fill: :black)
#     # |> render_date(t)
#     #TODO tags
#     |> render_tags(%{tags: t.tags, coords: {tl_x, tl_y}})
#     #TODO (dropdown, edit, close - toolbar)
#     |> Scenic.Primitives.text(t.created |> human_formatted_date(),
#             font: :ibm_plex_mono,
#             translate: {tl_x+left_margin, tl_y+top_margin+title_height}, # text draws from bottom-left corner??
#             font_size: 24,
#             fill: :grey)
#     |> Scenic.Primitives.text(t.data,
#             font: :ibm_plex_mono,
#             translate: {tl_x+left_margin, tl_y+top_margin+title_height*3}, # text draws from bottom-left corner??
#             font_size: 16,
#             fill: :black)
#   end

#   def render_tags(graph, %{tags: []}, _offset) do
#     graph
#   end

#   def render_tags(graph, %{tags: [tag|rest], coords: {tl_x, tl_y}}, offset \\ 0) do
#     # render_tags(graph, tags, :new_render)
#     IO.puts "ONCE"
#     left_margin = 60 #TODO this is from above lol
#     top_margin = 80
#     title_height = 60
#     why_not = 40
#     tag_width = 70

#     translate = {tl_x+left_margin+offset*tag_width, tl_y+top_margin+title_height+why_not}
#     translate_label = {tl_x+left_margin+offset*tag_width-10, tl_y+top_margin+title_height+why_not - 15}
#     tag_height = 20

#     graph
#     |> Scenic.Primitives.rounded_rectangle( {tag_width, tag_height, 12}, t: translate_label, fill: :red)
#     |> Scenic.Primitives.text(tag,
#           font: :ibm_plex_mono,
#           translate: translate, # text draws from bottom-left corner??
#           font_size: 14,
#           fill: :black)
#     |> render_tags(%{tags: rest, coords: {tl_x, tl_y}}, offset+1)
#   end

#   # def render_tags(graph, tags, :new_render) do
    
#   # end

#   def human_formatted_date(date) do
#     Logger.debug "parsing date: #{inspect date} into human readable format..."
#     {:ok, date, 0} = DateTime.from_iso8601(date)
#     day = case Date.day_of_week(date) do
#       1 -> "Mon"
#       2 -> "Tue"
#       3 -> "Wed"
#       4 -> "Thu"
#       5 -> "Fri"
#       6 -> "Sat"
#       7 -> "Sun"
#     end
#     month = case date.month do
#       1 -> "Jan"
#       2 -> "Feb"
#       3 -> "Mar"
#       4 -> "Apr"
#       5 -> "May"
#       6 -> "Jun"
#       7 -> "Jul"
#       8 -> "Aug"
#       9 -> "Sep"
#       10 -> "Oct"
#       11 -> "Nov"
#       12 -> "Dec"
#     end
#     #IO.inspect date
#     "#{day} #{date.day} #{month} #{date.year}"
#   end

#   def render_date(scene, %{created: date, modified: nil} = _tidbit) when is_bitstring(date) do
#     scene
#     |> Scenic.Primitives.text(date,
#             font: :ibm_plex_mono,
#             translate: {560, 240}, # text draws from bottom-left corner??
#             font_size: 36,
#             fill: :grey)
#   end

#   def render(scene, _params) do

#     todo_list = Memex.My.todos()
#     IO.inspect todo_list, label: "TODOs"

#     Scenic.Graph.build()
#     |> Scenic.Primitives.rect({800, 400}, translate: {500, 200}, fill: :lemon_chiffon)
#     |> Scenic.Primitives.line({{500, 300}, {1300, 300}}, stroke: {2, :green})
#     |> Scenic.Primitives.text("My TODO list",
#           font: :ibm_plex_mono,
#           translate: {560, 280}, # text draws from bottom-left corner??
#           font_size: 36,
#           fill: :black)
#     |> render_list(Enum.map(todo_list, & &1.title))

#     |> Scenic.Primitives.rect({800, 400}, translate: {500, 700}, fill: :lemon_chiffon)
#     |> Scenic.Primitives.line({{500, 800}, {1300, 800}}, stroke: {2, :green})
#     |> Scenic.Primitives.text("My other TODO list",
#           font: :ibm_plex_mono,
#           translate: {560, 780}, # text draws from bottom-left corner??
#           font_size: 36,
#           fill: :black)
#   end

#   def render_list(scene, list) do
#     render_list(scene, list, 0) # this is where we kickstart the recursion
#   end

#   def render_list(scene, [], _offset), do: scene

#   def render_list(scene, [item|rest], offset) do
#     scene
#     |> Scenic.Primitives.text("* " <> item,
#           font: :ibm_plex_mono,
#           translate: {560, 340+(offset*50)}, # text draws from bottom-left corner??
#           font_size: 36,                     # offset has to equal text size??
#           fill: :black)
#     |> render_list(rest, offset+1)
#   end
      
# end