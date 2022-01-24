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

		heading_font = %{
			name: :ibm_plex_mono,
			size: 36,
			metrics: Flamelex.Fluxus.RadixStore.fetch_font_metrics(:ibm_plex_mono)}
	
		init_graph =
			Scenic.Graph.build()
			|> Scenic.Primitives.group(
					fn graph ->
						graph
						|> Scenic.Primitives.rect(args.frame.size, fill: :white) # background rectangle
						|> ScenicWidgets.Simple.Heading.add_to_graph(%{
								text: args.state.title,
								frame: calc_title_frame(args.frame),
								font: heading_font,
								color: :green,
								# text_wrap_opts: :wrap #TODO
								background_color: :yellow
						}) #TODO theme: theme?? Does this get automatically passed down??
						|> Scenic.Components.button("Edit", id: {:edit_tidbit_btn, args.id}, translate: {args.frame.dimensions.width-100, 10})
						|> Scenic.Components.button("Close", id: {:close_tidbit_btn, args.id}, translate: {args.frame.dimensions.width-100, 60})
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

	def handle_event({:click, {:close_tidbit_btn, tidbit_uuid}}, _from, scene) do
        Flamelex.Fluxus.action({Flamelex.Fluxus.Reducers.Memex, {:close_tidbit, %{tidbit_uuid: tidbit_uuid}}})
        {:noreply, scene}
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
end
  

