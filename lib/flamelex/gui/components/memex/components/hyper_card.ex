defmodule Flamelex.GUI.Component.Memex.HyperCard do
    use Scenic.Component
    require Logger
	alias ScenicWidgets.Core.Structs.Frame
    
	@opts %{
		margin: 5
	}

	def validate(%{
			id: _id,
			frame: %Frame{} = _f,
			state: %{
				title: title
			}
	} = data) when is_bitstring(title) do
		Logger.debug("#{__MODULE__} accepted params: #{inspect(data)}")
		{:ok, data}
	end
	
	def init(scene, args, opts) do
		Logger.debug("#{__MODULE__} initializing...")
	
		theme =
			(opts[:theme] || Scenic.Primitive.Style.Theme.preset(:light))
			|> Scenic.Primitive.Style.Theme.normalize()

		init_graph =
			Scenic.Graph.build()
			|> Scenic.Primitives.group(
					fn graph ->
						graph |> render_tidbit(args)
					end,
					id: {__MODULE__, args.id},
					translate: args.frame.pin)
	
		init_scene =
			scene
			|> assign(graph: init_graph)
			|> assign(frame: args.frame)
			|> assign(state: args.state)
			|> push_graph(init_graph)
	
		{:ok, init_scene, {:continue, :publish_bounds}}
	end

	#         #TODO good idea: render each sub-component as a seperate graph,
#         #                calculate their heights, then use Scenic.Graph.add_to
#         #                to put them into the `:hypercard_itself` group
#         #                -> Unfortunately, this doesn't work because Scenic
#         #                doesn't seem to support "merging" 2 graphs, or
#         #                if I return a graph (each component), no way to
#         #                simply add that to another graph, as a sub-component

	def handle_continue(:publish_bounds, scene) do
        bounds = Scenic.Graph.bounds(scene.assigns.graph)

		Flamelex.GUI.Component.Memex.StoryRiver
		|> GenServer.cast({:new_component_bounds, {scene.assigns.state.uuid, bounds}})
        
        {:noreply, scene, {:continue, :render_next_hyper_card}}
    end

	def handle_continue(:render_next_hyper_card, scene) do
		Flamelex.GUI.Component.Memex.StoryRiver |> GenServer.cast(:render_next_component)
		{:noreply, scene}
	end

	def handle_event({:click, {:edit_tidbit_btn, tidbit_uuid}}, _from, scene) do
        Flamelex.Fluxus.action({Flamelex.Fluxus.Reducers.Memex, {:switch_mode, :edit, %{tidbit_uuid: tidbit_uuid}}})
        {:noreply, scene}
    end

	def handle_event({:click, {:save_tidbit_btn, tidbit_uuid}}, _from, scene) do
        Flamelex.Fluxus.action({Flamelex.Fluxus.Reducers.Memex, {:save_tidbit, %{tidbit_uuid: tidbit_uuid}}})
        {:noreply, scene}
    end

	def handle_event({:click, {:close_tidbit_btn, tidbit_uuid}}, _from, scene) do
        Flamelex.Fluxus.action({Flamelex.Fluxus.Reducers.Memex, {:close_tidbit, %{tidbit_uuid: tidbit_uuid}}})
        {:noreply, scene}
    end

	def handle_event({:click, {:discard_changes_btn, tidbit_uuid}}, _from, scene) do
        Flamelex.Fluxus.action({Flamelex.Fluxus.Reducers.Memex, {:switch_mode, :read_only, %{tidbit_uuid: tidbit_uuid}}})
        {:noreply, scene}
    end


	def render_tidbit(graph, %{state: %{edit_mode?: true, data: text} = tidbit, frame: frame} = args)
	when is_bitstring(text) do

		# - work on body component displaying how we actually want it to work
		# - wraps at correct width
		# - renders infinitely long
		# - only works for pure text, shows "NOT AVAILABLE" or whatever otherwise (centered ;)

		background_color = :red



		#TODO here we need to pre-calculate the height of the TidBit
		# body_height = calc_wrapped_text_height(%{frame: frame, text: data})
		# this is a workaround because of flex_grow
		{width, {:flex_grow, %{min_height: min_height}}} = frame.size
		frame_size = {width, min_height}

		graph
		|> Scenic.Primitives.rect(frame_size, fill: background_color) # background rectangle
		|> ScenicWidgets.Simple.Heading.add_to_graph(%{
				text: tidbit.title,
				frame: calc_title_frame(frame),
				font: heading_font(),
				color: :green,
				# text_wrap_opts: :wrap #TODO
				background_color: :yellow
		}) #TODO theme: theme?? Does this get automatically passed down??
		|> Scenic.Components.button("Save", id: {:save_tidbit_btn, args.id}, translate: {frame.dimensions.width-100, 10})
		|> Scenic.Components.button("Discard", id: {:discard_changes_btn, args.id}, translate: {frame.dimensions.width-100, 60})
		|> render_tags_box(%{mode: :edit, tidbit: tidbit, frame: frame})
		|> render_text_pad(%{mode: :edit, tidbit: tidbit, frame: frame})
	end

	# def render_tidbit(graph, %{state: %{edit_mode?: false} = tidbit, frame: frame} = args) do
	#NOTE: For now have this case here as a catch-all, but better to really match on a mode
	def render_tidbit(graph, %{state: tidbit, frame: frame} = args) do

		#TODO here we need to pre-calculate the height of the TidBit
		# this is a workaround because of flex_grow
		{width, {:flex_grow, %{min_height: min_height}}} = frame.size
		frame_size = {width, min_height}

		graph
		|> Scenic.Primitives.rect(frame_size, fill: :antique_white) # background rectangle
		|> ScenicWidgets.Simple.Heading.add_to_graph(%{
				text: tidbit.title,
				frame: calc_title_frame(frame),
				font: heading_font(),
				color: :green,
				# text_wrap_opts: :wrap #TODO
				background_color: :yellow
		}) #TODO theme: theme?? Does this get automatically passed down??
		|> Scenic.Components.button("Edit", id: {:edit_tidbit_btn, args.id}, translate: {frame.dimensions.width-100, 10})
		|> Scenic.Components.button("Close", id: {:close_tidbit_btn, args.id}, translate: {frame.dimensions.width-100, 60})
		|> render_dateline(tidbit)
		|> render_tags_box(%{mode: :read_only, tidbit: tidbit, frame: frame})
		|> render_text_pad(%{mode: :read_only, tidbit: tidbit, frame: frame})
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
			size: {hypercard_frame.dimensions.width*0.72, {:max_lines, 2}})
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



	def render_tags_box(graph, %{mode: :read_only, tidbit: tidbit, frame: hypercard_frame}) do
		tags_box_frame = Frame.new(pin: {@opts.margin, 140}, size: {hypercard_frame.dimensions.width-(2*@opts.margin), 80})

		# f = Frame.new(
		# 	pin: {@opts.margin, 150},
		# 	size: {hypercard_frame.dimensions.width-(2*@opts.margin), 170})

		graph
		|> Scenic.Primitives.group(
			fn graph ->
				graph
				|> Scenic.Primitives.rect(tags_box_frame.size, fill: :green)
				|> render_tags(tidbit |> Map.merge(%{coords: tags_box_frame.pin}))
			end,
			translate: tags_box_frame.pin)
	end

	def render_tags_box(graph, %{mode: :edit, tidbit: tidbit, frame: hypercard_frame}) do
		tags_box_frame = Frame.new(pin: {@opts.margin, 140}, size: {hypercard_frame.dimensions.width-(2*@opts.margin), 80})

		# f = Frame.new(
		# 	pin: {@opts.margin, 150},
		# 	size: {hypercard_frame.dimensions.width-(2*@opts.margin), 170})

		graph
		|> Scenic.Primitives.group(
			fn graph ->
				graph
				|> Scenic.Primitives.rect(tags_box_frame.size, fill: :yellow)
				|> render_tags(tidbit)
			end,
			translate: tags_box_frame.pin)

	end

	def render_tags(graph, %{tags: []}, _offset) do
		graph
	end

	def render_tags(graph, %{tags: [tag|rest]}, offset \\ 0) do
	    # render_tags(graph, tags, :new_render)
	    # IO.puts "ONCE"
	    # left_margin = 60 #TODO this is from above lol
	    # top_margin = 80
	    # title_height = 60
	    # why_not = 40
		
	    # translate = {tl_x+left_margin+offset*tag_width, tl_y+top_margin+title_height+why_not}
	    # translate_label = {tl_x+left_margin+offset*tag_width-10, tl_y+top_margin+title_height+why_not - 15}

	    tag_width = 70
	    tag_height = 20
		tag_color = :red

		tag_translation = {@opts.margin+(offset*tag_width), @opts.margin}

	    graph
		|> Scenic.Primitives.group( # render a single tag
				fn graph ->
					graph
					|> Scenic.Primitives.rounded_rectangle({tag_width, tag_height, 8}, fill: tag_color)
					|> Scenic.Primitives.text(tag,
						font: :ibm_plex_mono,
						translate: {10, 15}, # text draws from bottom-left corner??
						font_size: 14,
						fill: :black)
				end,
				translate: tag_translation)
	    |> render_tags(%{tags: rest}, offset+1)
	end

	def render_text_pad(graph, %{mode: mode, tidbit: tidbit, frame: hypercard_frame}) do

		graph
		|> ScenicWidgets.TextPad.add_to_graph(%{
				frame: calc_body_frame(hypercard_frame),
				text: tidbit.data,
				mode: mode,
				format_opts: %{
					alignment: :left,
					wrap_opts: {:wrap, :end_of_line},
					show_line_num?: false
				},
				font: %{
					name: heading_font().name,
					size: 24,
					metrics: heading_font().metrics
				}
		})
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

	def calc_body_frame(hypercard_frame) do
		#REMINDER: Because we render this from within the group (which is
		#		   already getting translated, we only need be concerned
		#		   here with the _relative_ offset from the group. Or
		#		   in other words, this is all referenced off the top-left
		#		   corner of the HyperCard, not the top-left corner
		#		   of the screen.
		Frame.new(
			pin: {@opts.margin, 240},
			size: {hypercard_frame.dimensions.width-(2*@opts.margin), 170})
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

	defp heading_font do
		# This is just the font details for the TidBit/HyperCard heading
		%{
			name: :ibm_plex_mono,
			size: 36,
			metrics: Flamelex.Fluxus.RadixStore.fetch_font_metrics(:ibm_plex_mono)
		}
	end
end
