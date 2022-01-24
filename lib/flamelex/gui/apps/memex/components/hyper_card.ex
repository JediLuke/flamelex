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
	
		{:ok, init_scene}
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

	def render_tidbit(graph, %{state: %{edit_mode?: true, data: text} = tidbit, frame: frame} = args)
	when is_bitstring(text) do

		background_color = :red

		heading_font = %{
			name: :ibm_plex_mono,
			size: 36,
			metrics: Flamelex.Fluxus.RadixStore.fetch_font_metrics(:ibm_plex_mono)}

		graph
		|> Scenic.Primitives.rect(frame.size, fill: background_color) # background rectangle
		|> ScenicWidgets.Simple.Heading.add_to_graph(%{
				text: tidbit.title,
				frame: calc_title_frame(frame),
				font: heading_font,
				color: :green,
				# text_wrap_opts: :wrap #TODO
				background_color: :yellow
		}) #TODO theme: theme?? Does this get automatically passed down??
		|> Scenic.Components.button("Save", id: {:save_tidbit_btn, args.id}, translate: {frame.dimensions.width-100, 10})
		# |> ScenicWidgets.FrameBox.add_to_graph(%{frame: calc_body_frame(frame), color: :blue})
		|> Scenic.Primitives.rrect({frame.dimensions.width-(2*@opts.margin), 170, 12}, t: {@opts.margin, 100}, fill: :pink)
		# |> ScenicWidgets.TextPad.add_to_graph(%{
		# 		frame: calc_body_frame(frame),
		# 		text: tidbit.data,
		# 		format_opts: %{
		# 			alignment: :left,
		# 			wrap_opts: {:wrap, :end_of_line},
		# 			show_line_num?: false
		# 		},
		# 		font: %{
		# 			name: heading_font.name,
		# 			size: 24,
		# 			metrics: heading_font.metrics
		# 		}
		# })
		# |> Scenic.Components.button("Close", id: {:close_tidbit_btn, args.id}, translate: {frame.dimensions.width-100, 60})
	end

	def render_tidbit(graph, %{state: tidbit, frame: frame} = args) do

		background_color = :antique_white

		heading_font = %{
			name: :ibm_plex_mono,
			size: 36,
			metrics: Flamelex.Fluxus.RadixStore.fetch_font_metrics(:ibm_plex_mono)}

		graph
		|> Scenic.Primitives.rect(frame.size, fill: background_color) # background rectangle
		|> ScenicWidgets.Simple.Heading.add_to_graph(%{
				text: tidbit.title,
				frame: calc_title_frame(frame),
				font: heading_font,
				color: :green,
				# text_wrap_opts: :wrap #TODO
				background_color: :yellow
		}) #TODO theme: theme?? Does this get automatically passed down??
		|> Scenic.Components.button("Edit", id: {:edit_tidbit_btn, args.id}, translate: {frame.dimensions.width-100, 10})
		|> Scenic.Components.button("Close", id: {:close_tidbit_btn, args.id}, translate: {frame.dimensions.width-100, 60})
		|> ScenicWidgets.TextPad.add_to_graph(%{
				frame: calc_body_frame(frame),
				mode: :read_only,
				text: tidbit.data,
				format_opts: %{
					alignment: :left,
					wrap_opts: {:wrap, :end_of_line},
					show_line_num?: false
				},
				font: %{
					name: heading_font.name,
					size: 24,
					metrics: heading_font.metrics
				}
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
			size: {hypercard_frame.dimensions.width*0.72, {:max_lines, 2}})
	end

	def calc_body_frame(hypercard_frame) do
		#REMINDER: Because we render this from within the group (which is
		#		   already getting translated, we only need be concerned
		#		   here with the _relative_ offset from the group. Or
		#		   in other words, this is all referenced off the top-left
		#		   corner of the HyperCard, not the top-left corner
		#		   of the screen.
		Frame.new(
			pin: {@opts.margin, 150},
			size: {hypercard_frame.dimensions.width-(2*@opts.margin), 170})
	end
end
  

