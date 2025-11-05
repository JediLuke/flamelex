defmodule Flamelex.GUI.Component.HighCouncil.Render do
  @moduledoc """
  This module serves as a container for very complex render functions
  to avoid cluttering up the components.
  """
  alias Widgex.Frame
  alias Widgex.Frame.Grid
  alias Flamelex.GUI.Component.HighCouncil.State
  alias Memelex.Lib.Structs.MemexConcepts.V01.Agent

  def go(%Frame{} = frame, %State{new_agent_mode?: new_agent_mode?} = state)
      when is_boolean(new_agent_mode?) do
    # Define a grid with a banner, a large middle frame, and a footer
    grid =
      Grid.new(frame)
      # 10% for banner, 80% for middle, 10% for footer
      |> Grid.rows([0.10, 0.80, 0.10])
      # One column taking 100% of the width
      |> Grid.columns([1.0])
      |> Grid.define_areas(%{
        # Banner area spanning the first row
        banner: {0, 0, 1, 1},
        # Large middle area spanning the second row
        mid_section: {1, 0, 1, 1},
        # Footer area spanning the third row
        footer: {2, 0, 1, 1}
      })

    # Grid.new(frame)
    # |> Grid.rows([0.10, 0.35, 0.35, 0.20])
    # |> Grid.columns([1.0 / 3.0, 1.0 / 3.0, 1.0 / 3.0])
    # |> Grid.row_gap(0)
    # |> Grid.column_gap(0)
    # |> Grid.define_areas(%{
    #   banner: {0, 0, 1, 3},
    #   footer: {3, 0, 1, 3},
    #   tile1: {1, 0, 1, 1},
    #   tile2: {1, 1, 1, 1},
    #   tile3: {1, 2, 1, 1},
    #   tile4: {2, 0, 1, 1},
    #   tile5: {2, 1, 1, 1},
    #   tile6: {2, 2, 1, 1}
    # })

    # Calculate the frames
    cell_frames = Grid.calculate(grid)

    # Retrieve frames for banner and footer
    banner_frame = Grid.area_frame(grid, cell_frames, :banner)
    footer_frame = Grid.area_frame(grid, cell_frames, :footer)
    middle_frame = Grid.area_frame(grid, cell_frames, :mid_section)
    # t3 = Grid.area_frame(grid, cell_frames, :tile3)

    # Build the graph
    graph =
      Scenic.Graph.build()
      |> Scenic.Primitives.group(fn graph ->
        graph
        |> Flamelex.GUI.Utils.Draw.background(frame, :grey)
        |> render_title(banner_frame, %{})
        # |> render_agent_card(t3, hd(state.agents))
        |> render_agents(middle_frame, state)
        |> render_tools(footer_frame)
      end)

    # Conditionally render the new agent modal
    if new_agent_mode? do
      maybe_render_new_agent_modal(graph, frame, state)
    else
      graph
    end
  end

  def render_title(graph, %Widgex.Frame{} = f, _args) do
    graph
    |> Scenic.Primitives.rectangle(f.size.box, fill: :green, t: f.pin.point)
    |> ScenicWidgets.Markup.Header1.draw(%{
      frame: f,
      text: "High Council",
      color: :white
    })
  end

  def render_agents(graph, %Widgex.Frame{} = f, %State{} = state) do
    agents = state.agents
    total_agents = length(agents)

    if total_agents >= 1 do
      IO.inspect(total_agents, label: "NUM SAGENTS")
      # Define a grid with 6 rows and 4 columns
      grid =
        Grid.new(f)
        # 6 equal rows
        |> Grid.rows(List.duplicate(1.0 / 6, 6))
        # 4 equal columns
        |> Grid.columns(List.duplicate(1.0 / 4, 4))
        # Add row gap for spacing
        |> Grid.row_gap(2)
        # Add column gap for spacing
        |> Grid.column_gap(2)
        |> Grid.define_areas(
          Enum.reduce(1..total_agents, %{}, fn idx, acc ->
            # Dynamically define the grid areas for agents
            Map.put(acc, :"agent#{idx}", {div(idx - 1, 4), rem(idx - 1, 4), 1, 1})
          end)
        )

      # Calculate the frames for the grid layout
      agent_frames = Grid.calculate(grid)

      # Dynamically render each agent card
      Enum.reduce(1..total_agents, graph, fn idx, graph_acc ->
        area_name = :"agent#{idx}"
        frame = Grid.area_frame(grid, agent_frames, area_name)
        agent = Enum.at(agents, idx - 1)

        render_agent_card(graph_acc, frame, agent)
      end)
    else
      graph
    end
  end

  # def render_agents(graph, %Widgex.Frame{} = f, %State{} = state) do
  #   agents = state.agents

  #   # Calculate the number of columns based on the number of agents
  #   num_columns = if length(agents) > 3, do: 3, else: length(agents)

  #   # Define a grid with the number of columns based on the number of agents
  #   grid =
  #     Grid.new(f)
  #     # |> Grid.rows([0.35, 0.35, 0.35])
  #     |> Grid.rows([0.5, 0.5])
  #     |> Grid.columns(Enum.map(1..num_columns, fn _ -> 1.0 / num_columns end))
  #     |> Grid.define_areas(%{
  #       agent1: {0, 0, 1, 1},
  #       agent2: {0, 1, 1, 1},
  #       agent3: {0, 2, 1, 1}
  #     })

  #   # Calculate the frames based on the grid layout
  #   agent_frames = Grid.calculate(grid)
  #   agent1_frame = Grid.area_frame(grid, agent_frames, :agent1)
  #   agent2_frame = Grid.area_frame(grid, agent_frames, :agent2)
  #   agent3_frame = Grid.area_frame(grid, agent_frames, :agent3)

  #   # Render the agent cards
  #   graph
  #   |> render_agent_card(agent1_frame, hd(agents))
  #   |> render_agent_card(agent2_frame, hd(tl(agents)))
  #   |> render_agent_card(agent3_frame, hd(tl(tl(agents))))
  # end

  def render_agent_card(graph, _frame, nil) do
    graph
  end

  def render_agent_card(
        graph,
        %Widgex.Frame{} = f,
        %Memelex.TidBit{
          data: %Agent{config: %{"mfa" => {agent_module, :start_link, [_args]}}} = agent
        } = tidbit
      ) do
    # Fetch the agent state
    # agent_state = agent_module.get_state()

    # Define the grid structure for title and status
    grid =
      Grid.new(f)
      # 20% for title, 30% spacing, 50% for status
      |> Grid.rows([0.2, 0.3, 0.5])
      # Single column layout
      |> Grid.columns([1.0])
      |> Grid.define_areas(%{
        # Title section
        title: {0, 0, 1, 1},
        # Status section
        status: {2, 0, 1, 1}
      })

    # Calculate the frames
    frames = Grid.calculate(grid)
    title_frame = Grid.area_frame(grid, frames, :title)
    status_frame = Grid.area_frame(grid, frames, :status)

    # Render the card with click interaction
    graph
    |> Scenic.Primitives.group(fn graph ->
      # Background rectangle, now clickable with :input
      graph
      |> Scenic.Primitives.rectangle(f.size.box,
        fill: (if agent.status == :active, do: :blue, else: :orange),
        t: f.pin.point,
        id: {:agent_card, tidbit.uuid},
        input: :cursor_button
      )

      # Title section (agent's name)
      |> ScenicWidgets.Markup.Header1.draw(%{
        frame: title_frame,
        text: agent.name,
        color: :white
      })

      # # Status section (agent's state)
      # |> Scenic.Primitives.text("Status: #{inspect(agent_state)}",
      #   font_size: 14,
      #   translate: {f.pin.x + 10, f.pin.y + 10}
      # )
    end)
  end

  def render_tools(graph, %Widgex.Frame{} = f) do
    IO.puts "happening..."
    graph
    # |> Flamelex.GUI.Utils.Draw.background(f, :grey, translate: f.pin.point)
    |> Scenic.Components.button("New agent",
      id: :new_agent,
      t: {70, 67}
      # translate: {f.pin.x + 100, f.pin.y + 100}
      # translate: Widgex.Frame.center(f).point
    )
  end

  def maybe_render_new_agent_modal(graph, %Frame{} = frame, %State{} = state) do
    # Create a new grid for the modal, which will be the middle third and 80% height
    modal_grid =
      Grid.new(frame)
      # 85% height in the middle
      # Adjust to make the modal slightly larger (85% height)
      |> Grid.rows([0.075, 0.85, 0.075])
      # Modal in the middle third, slightly wider (e.g., 66% of the width)
      # Adjust to make the modal wider
      |> Grid.columns([0.17, 0.66, 0.17])
      |> Grid.define_areas(%{
        # Centered modal
        modal: {1, 1, 1, 1}
      })

    # Calculate the frames for the modal
    modal_frames = Grid.calculate(modal_grid)
    modal_frame = Grid.area_frame(modal_grid, modal_frames, :modal)

    # Render the modal and overlay
    graph
    |> Scenic.Primitives.group(fn graph ->
      graph
      # Draw a semi-transparent overlay to grey out the background
      |> Scenic.Primitives.rectangle(frame.size.box,
        # Semi-transparent grey to see background
        # fill: {:color, :black, 128},
        fill: {:color_rgba, {0, 0, 0, 172}},
        t: frame.pin.point
      )

      # Draw the modal itself
      |> render_modal_box(modal_frame, state)
    end)
  end

  defp render_modal_box(graph, %Widgex.Frame{} = f, _state) do
    # Define a new grid to split the modal into a title, body, and buttons at the bottom
    modal_grid =
      Grid.new(f)
      # Title (20%), Body (60%), Buttons (20%)
      |> Grid.rows([0.2, 0.6, 0.2])
      # Single column
      |> Grid.columns([1.0])
      |> Grid.define_areas(%{
        title: {0, 0, 1, 1},
        body: {1, 0, 1, 1},
        buttons: {2, 0, 1, 1}
      })

    # Calculate the frames based on the grid layout
    modal_frames = Grid.calculate(modal_grid)
    title_frame = Grid.area_frame(modal_grid, modal_frames, :title)
    body_frame = Grid.area_frame(modal_grid, modal_frames, :body)
    buttons_frame = Grid.area_frame(modal_grid, modal_frames, :buttons)

    # Use rrect to create a rounded rectangle for the modal
    graph
    |> Scenic.Primitives.rrect({f.size.width, f.size.height, 20},
      fill: :white,
      t: {f.pin.x, f.pin.y - 15}
    )

    # Title section
    |> ScenicWidgets.Markup.Header1.draw(%{
      frame: title_frame,
      text: "Enter new agent details",
      color: :black
    })

    # Body section (add label and text input field for "Name")
    |> Scenic.Primitives.text("Name:",
      font_size: 18,
      fill: :black,
      translate: {body_frame.pin.x + 20, body_frame.pin.y + 20}
    )
    |> Scenic.Components.text_field("",
      id: :agent_name,
      translate: {body_frame.pin.x + 100, body_frame.pin.y + 16},
      # Adjust the width of the text field
      width: 300
    )

    # Buttons section (with two centered buttons)
    |> Scenic.Components.button("Cancel",
      id: :cancel_modal,
      translate: {buttons_frame.pin.x + f.size.width / 2 - 90, buttons_frame.pin.y + 20}
    )
    |> Scenic.Components.button("Save",
      id: :save_agent,
      translate: {buttons_frame.pin.x + f.size.width / 2 + 10, buttons_frame.pin.y + 20}
    )
  end
end
