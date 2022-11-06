defmodule Flamelex.GUI.Component.Memex.HyperCard.Utils do
    # just a function for splitting of code into to help organise
    # the HyperCard module
    alias ScenicWidgets.Core.Structs.Frame
    require Logger

    @opts %{
		margin: 5
	}

	@heading_1 36 # The font size for top-level headings

    def default_mode(%{mode: existing_mode} = state, _default_mode) do
        state
    end

    def default_mode(state, default_mode) do
        state |> Map.merge(%{mode: default_mode})
    end

    def render(args) do
        Scenic.Graph.build()
        |> Scenic.Primitives.group(
                fn graph -> graph |> render_tidbit(args) end,
            id: {__MODULE__, args.id},
            translate: args.frame.pin)
    end

	#TODO write a blog post about using matches to distinguish the case vs just for convenience (if for convenience, do it inside the function)
    def render_tidbit(graph, %{state: %{
			mode: :edit,
			activate: :title, data: text} = tidbit} = args)
	when is_bitstring(text) do

		# - work on body component displaying how we actually want it to work
		# - wraps at correct width
		# - renders infinitely long
		# - only works for pure text, shows "NOT AVAILABLE" or whatever otherwise (centered ;)

		background_color = :red
		frame = args.frame


		#TODO here we need to pre-calculate the height of the TidBit
		# body_height = calc_wrapped_text_height(%{frame: frame, text: data})
		# this is a workaround because of flex_grow
		{width, {:flex_grow, %{min_height: min_height}}} = frame.size
		frame_size = {width, min_height}

		graph
		|> Scenic.Primitives.rect(frame_size, fill: background_color) # background rectangle
		|> render_heading(tidbit, frame, mode: :edit)
		|> Scenic.Components.button("Save", id: {:save_tidbit_btn, args.id}, translate: {frame.dimensions.width-100, 10})
		|> Scenic.Components.button("Discard", id: {:discard_changes_btn, args.id}, translate: {frame.dimensions.width-100, 60})
		|> render_tags_box(%{mode: :edit, tidbit: tidbit, frame: frame})
		|> render_text_pad(%{mode: :read_only, tidbit: tidbit, frame: frame})
	end

	def render_tidbit(graph, %{state: %{
			mode: :edit,
			activate: :body, data: text} = tidbit} = args)
	when is_bitstring(text) do

		# - work on body component displaying how we actually want it to work
		# - wraps at correct width
		# - renders infinitely long
		# - only works for pure text, shows "NOT AVAILABLE" or whatever otherwise (centered ;)

		background_color = :pink
		frame = args.frame


		#TODO here we need to pre-calculate the height of the TidBit
		# body_height = calc_wrapped_text_height(%{frame: frame, text: data})
		# this is a workaround because of flex_grow
		{width, {:flex_grow, %{min_height: min_height}}} = frame.size
		frame_size = {width, min_height}

		graph
		|> Scenic.Primitives.rect(frame_size, fill: background_color) # background rectangle
		|> render_heading(tidbit, frame)
		|> Scenic.Components.button("Save", id: {:save_tidbit_btn, args.id}, translate: {frame.dimensions.width-100, 10})
		|> Scenic.Components.button("Discard", id: {:discard_changes_btn, args.id}, translate: {frame.dimensions.width-100, 60})
		|> render_tags_box(%{mode: :edit, tidbit: tidbit, frame: frame})
		|> render_text_pad(%{mode: :edit, tidbit: tidbit, frame: frame})
	end

	def render_tidbit(graph, %{state: %{
			mode: :read_only,
			data: text} = tidbit, frame: frame} = args)
	when is_bitstring(text) do

		#TODO here we need to pre-calculate the height of the TidBit
		# this is a workaround because of flex_grow
		{width, {:flex_grow, %{min_height: min_height}}} = frame.size
		frame_size = {width, min_height}

		graph
		|> Scenic.Primitives.rect(frame_size, fill: :antique_white) # background rectangle
		|> render_heading(tidbit, frame)
		|> Scenic.Components.button("Edit", id: {:edit_tidbit_btn, args.id}, translate: {frame.dimensions.width-100, 10})
		|> Scenic.Components.button("Close", id: {:close_tidbit_btn, args.id}, translate: {frame.dimensions.width-100, 60})
		|> render_dateline(tidbit)
		|> render_tags_box(%{mode: :read_only, tidbit: tidbit, frame: frame})
		|> render_text_pad(%{mode: :read_only, tidbit: tidbit, frame: frame})
	end

	# def render_tidbit(graph, %{state: %{edit_mode?: false} = tidbit, frame: frame} = args) do
	#NOTE: For now have this case here as a catch-all, but better to really match on a mode
	#NOTE: THis case means we failed to match any known case for rendering the body
	def render_tidbit(graph, %{state: tidbit, frame: frame} = args) do
		Logger.error "Could not successfully render TidBit: #{inspect tidbit}"

		#TODO here we need to pre-calculate the height of the TidBit
		# this is a workaround because of flex_grow
		{width, {:flex_grow, %{min_height: min_height}}} = frame.size
		frame_size = {width, min_height}

		graph
		|> Scenic.Primitives.rect(frame_size, fill: :antique_white) # background rectangle
		|> render_heading(tidbit, frame)
		|> Scenic.Components.button("Edit", id: {:edit_tidbit_btn, args.id}, translate: {frame.dimensions.width-100, 10})
		|> Scenic.Components.button("Close", id: {:close_tidbit_btn, args.id}, translate: {frame.dimensions.width-100, 60})
		|> render_dateline(tidbit)
		|> render_tags_box(%{mode: :read_only, tidbit: tidbit, frame: frame})
		|> show_unrenderable_box(%{tidbit: tidbit, frame: frame})
	end

	def render_heading(graph, tidbit, frame) do
		Logger.warn "DEPRECATE ME543"
		render_heading(graph, tidbit, frame, mode: :read_only)
	end

	def render_heading(graph, tidbit, frame, mode: mode) do
		graph

		# |> Scenic.Primitives.group(
		# 	fn graph ->
		# 	  graph
		# 	#   |> Scenic.Primitives.rect(heading_rectangular_size,
		# 	# 	fill: background_color
		# 	#   )
		# 	  |> Scenic.Primitives.text(wrapped_text,
		# 		font: font_name,
		# 		font_size: font_size,
		# 		translate: {0, vpos},
		# 		fill: font_color
		# 	  )
		# 	end,
		# 	scissor: heading_rectangular_size,
		# 	# translate: {tl_x+left_margin, tl_y+top_margin}, # text draws from bottom-left corner??
		# 	translate: args.frame.pin
		#   )


		|> ScenicWidgets.TextPad.add_to_graph(%{
			id: "__heading__" <> tidbit.uuid,
			frame: calc_title_frame(frame),
			text: tidbit.title,
			cursor: Map.get(tidbit, :cursor, 0),
			mode: mode,
			format_opts: %{
				alignment: :left,
				wrap_opts: {:wrap, :end_of_line},
				show_line_num?: false
			},
			font: ibm_plex_mono(size: @heading_1)
		})
		# |> ScenicWidgets.Simple.Heading.add_to_graph(%{
		# 	text: tidbit.title,
		# 	frame: calc_title_frame(frame),
		# 	font: heading_font(),
		# 	color: :green,
		# 	# text_wrap_opts: :wrap #TODO
		# 	background_color: :yellow
		# }) #TODO theme: theme?? Does this get automatically passed down??
	end

    def render_tags_box(graph, %{mode: :read_only, tidbit: tidbit, frame: hypercard_frame}) do
		tags_box_frame =
			Frame.new(pin: {@opts.margin, 140},
					 size: {hypercard_frame.dimensions.width-(2*@opts.margin), 80})

		graph
		|> Scenic.Primitives.group(
			fn graph ->
				graph
				|> Scenic.Primitives.rect(tags_box_frame.size, fill: :green)
				|> Flamelex.GUI.Component.Layout.add_to_graph(%{
					frame: tags_box_frame,
					components: tags_list(tidbit),
					layout: :inline_block
				})
			end,
			translate: tags_box_frame.pin)
	end

	def render_tags_box(graph, %{mode: :edit, tidbit: tidbit, frame: hypercard_frame}) do
		tags_box_frame =
			Frame.new(pin: {@opts.margin, 140},
					 size: {hypercard_frame.dimensions.width-(2*@opts.margin), 80})

		graph
		|> Scenic.Primitives.group(
			fn graph ->
				graph
				|> Scenic.Primitives.rect(tags_box_frame.size, fill: :yellow)
				|> Flamelex.GUI.Component.Layout.add_to_graph(%{
						frame: tags_box_frame,
						components: tags_list(tidbit),
						layout: :inline_block
				})
			end,
			translate: tags_box_frame.pin)
	end


	def tags_list(%{tags: tags}) do
		tags_list([], tags)
	end

	def tags_list(acc, []), do: acc

	def tags_list(acc, [tag|rest]) when is_bitstring(tag) do
		tag_render_fn =
			fn(graph, %{frame: frame}) ->
				
				{:flex_grow, %{min_width: tag_width}} = frame.dimensions.width #TODO calculate real width from text width

				#TODO ok this needs to be it's own component, so it can call back & report it's own size
				graph
				|> Flamelex.GUI.Component.Layoutable.add_to_graph(%{
					render_fn: fn(graph, %{frame: frame}) ->
						graph
						|> Scenic.Primitives.group( # render a single tag
						fn graph ->
							graph
							|> Scenic.Primitives.rounded_rectangle({tag_width, frame.dimensions.height, 10}, fill: :yellow)
							|> Scenic.Primitives.text(tag,
								font: :ibm_plex_mono,
								translate: {10, 15}, # text draws from bottom-left corner??
								font_size: 14, #TODO get this from somewhere better
								fill: :black)
						end,
						translate: frame.pin)
					end
				})
			end

		tags_list(acc ++ [tag_render_fn], rest)
	end

	def render_dateline(graph, tidbit) do
		graph
		|> Scenic.Primitives.text(
				tidbit.created |> human_formatted_date(),
					font: :ibm_plex_mono,
					translate: {@opts.margin, 128},
					font_size: 24,
					fill: :dark_grey)
	end

	def render_text_pad(graph, %{mode: mode, tidbit: tidbit, frame: hypercard_frame}) do
		graph
		|> ScenicWidgets.TextPad.add_to_graph(%{
				id: tidbit.uuid,
				frame: calc_body_frame(hypercard_frame),
				text: tidbit.data,
				cursor: Map.get(tidbit, :cursor, 0),
				mode: mode,
				format_opts: %{
					alignment: :left,
					wrap_opts: {:wrap, :end_of_line},
					show_line_num?: false
				},
				font: ibm_plex_mono(size: 24) #TODO use a better name like #heading_2 or something
		})
	end

	def calc_title_frame(hypercard_frame) do
		#REMINDER: Because we render this from within the group (which is
		#		   already getting translated, we only need be concerned
		#		   here with the _relative_ offset from the group. Or
		#		   in other words, this is all referenced off the top-left
		#		   corner of the HyperCard, not the top-left corner
		#		   of the screen.
		Frame.new(
			pin: {@opts.margin, @opts.margin},
			# size: {hypercard_frame.dimensions.width*0.72, {:max_lines, 2}})
			size: {hypercard_frame.dimensions.width*0.72, 100}) #TODO get real height somewhere
	end

	def calc_body_frame(hypercard_frame) do
		#REMINDER: Because we render this from within the group (which is
		#		   already getting translated, we only need be concerned
		#		   here with the _relative_ offset from the group. Or
		#		   in other words, this is all referenced off the top-left
		#		   corner of the HyperCard, not the top-left corner
		#		   of the screen.
		Frame.new(
			pin: {@opts.margin, 225},
			size: {hypercard_frame.dimensions.width-(2*@opts.margin), 270})
	end

	def show_unrenderable_box(graph, %{tidbit: tidbit, frame: hypercard_frame}) do
		Logger.error "Unable to render TidBit: #{inspect tidbit}"
		body_frame = calc_body_frame(hypercard_frame)
		graph
		|> Scenic.Primitives.rrect(
			{body_frame.dimensions.width, body_frame.dimensions.height, 12},
			fill: :red,
			stroke: {2, :white},
			scissor: body_frame.size,
			translate: body_frame.pin
		  )
	end

	def human_formatted_date(date) do
		Logger.debug "parsing date: #{inspect date} into human readable format..."
		{:ok, date, 0} = DateTime.from_iso8601(date)
		#IO.inspect date
		day = case Date.day_of_week(date) do
				1 -> "Mon"
				2 -> "Tue"
				3 -> "Wed"
				4 -> "Thu"
				5 -> "Fri"
				6 -> "Sat"
				7 -> "Sun"
			end
		month = case date.month do
				1 -> "Jan"
				2 -> "Feb"
				3 -> "Mar"
				4 -> "Apr"
				5 -> "May"
				6 -> "Jun"
				7 -> "Jul"
				8 -> "Aug"
				9 -> "Sep"
				10 -> "Oct"
				11 -> "Nov"
				12 -> "Dec"
			end
		"#{day} #{date.day} #{month} #{date.year}"
	end

	# defp heading_font do
	# 	# This is just the font details for the TidBit/HyperCard heading
	# 	Flamelex.Fluxus.RadixStore.get().fonts.ibm_plex_mono
	# 	|> Map.merge(%{size: 36})
	# end

	defp ibm_plex_mono(size: s) do
		Flamelex.Fluxus.RadixStore.get().fonts.ibm_plex_mono
		|> Map.merge(%{size: s})
	end


	#     @doc """
#     Calculates the render height of a bunch of text (after wrapping) for
#     a given frame (including margins!)
#     """
#     def calc_wrapped_text_height(%{frame: frame, text: unwrapped_text}) when is_bitstring(unwrapped_text) do

#         width = frame.dimensions.width
#         textbox_width = width-@margin.left-@margin.right

#         {:ok, metrics} = TruetypeMetrics.load("./assets/fonts/IBMPlexMono-Regular.ttf")
#         wrapped_text = FontMetrics.wrap(unwrapped_text, textbox_width, @font_size, metrics)

#         #NOTE: This tells us, how long the body will be - because in Scenic
#         #      we take the top-left corner as the origin, the bottom of
#         #      a bounding box is greater than the top. The total height
#         #      is the bottom minus the top.
#         {_left, top, _right, bottom} =
#             Scenic.Graph.build()
#             |> Scenic.Primitives.text(wrapped_text, font: :ibm_plex_mono, font_size: @font_size)
#             |> Scenic.Graph.bounds()
        
#         body_height = (bottom-top)+@margin.top+@margin.bottom

#         if body_height <= @min_body_height do
#             @min_body_height
#         else
#             body_height
#         end
#     end

#     def calc_wrapped_text_height(_otherwise) do
#         @min_body_height
#     end


end