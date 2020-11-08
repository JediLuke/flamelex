defmodule Flamelex.API.GUI.Utilities.Drawing.TextComponentDrawingLib do
  use Flamelex.ProjectAliases


  @newline_character "\n"
  @left_margin 4



  def render_text_grid(graph, %{
        frame: frame,
        text: text,
        cursor_position: cursor_position,
        cursor_blink?: blink?,
        mode: mode
  }) do

    font_size = Flamelex.API.GUI.Fonts.size()

    # maybe we make each box, just slightly bigger than a character...
    box_buffer    = 1
    block_width   = box_buffer + GUI.FontHelpers.monospace_font_width(:ibm_plex_mono, font_size)
    block_height  = box_buffer + GUI.FontHelpers.monospace_font_height(:ibm_plex_mono, font_size)

    num_rows = frame.dimensions.height / block_height |> Float.ceil() |> trunc()
    num_cols = frame.dimensions.width  / block_width  |> Float.ceil() |> trunc()

    tiles = generate_tiles(%{
              text: text,
              row: num_rows, #TODO rename to max
              col: num_cols })

    opts = %{ block_width: block_width,
              block_height: block_height,
              cursor: cursor_position,
              cursor_blink?: blink?,
              mode: mode }

    graph
    |> render_tiles(frame, tiles, opts)
  end

  def render_text_grid(graph, %{
    frame: frame,
    text: text,
    cursor_position: cursor_position,
    cursor_blink?: blink?
  }) do
    render_text_grid(graph, %{
      frame: frame,
      text: text,
      cursor_position: cursor_position,
      cursor_blink?: blink?,
      mode: :normal #NOTE: add this in when this pattern-match hits #TODO remove this though
    })
  end

  # def render_text_grid(graph, frame, data, cursor_position) do

  #   # tiles =
  #   #   generate_tiles(%{
  #   #           text: data,
  #   #           #TOOD rename to max_
  #   #           # max_rows: num_rows,
  #   #           # max_cols: num_cols
  #   #           rows: num_rows,
  #   #           cols: num_cols
  #   #         })

  #   opts = %{
  #     block_width: @block_width,
  #     block_height: @block_width,
  #     cursor: cursor_position
  #   }

  #   graph
  #   |> render_tiles(frame, tiles, opts)
  # end

  def generate_tiles(%{text: text}) do

    {first_letter, remaining_text} = text |> String.split_at(1)

    recursively_generate_tiles(%{
          this_letter: first_letter,
          remaining_text: remaining_text,
          row: 0,
          col: 0
      },
      _accumulated_list_of_tiles_so_far = []
    )
  end

  def recursively_generate_tiles(%{remaining_text: ""}, accumulated_list_of_tiles_so_far) do
    # base case...
    accumulated_list_of_tiles_so_far
  end

  def recursively_generate_tiles(%{
        this_letter: @newline_character,
        remaining_text: remaining_text,
        row: row
  }, accumulated_list_of_tiles_so_far) do

    {next_letter, next_remaining_text} = remaining_text |> String.split_at(1)

    recursively_generate_tiles(%{
          this_letter: next_letter,
          remaining_text: next_remaining_text,
          row: row+1,
          col: 0
      },
      accumulated_list_of_tiles_so_far
    )
  end

  def recursively_generate_tiles(%{
        this_letter: this_letter,
        remaining_text: remaining_text,
        row: row,
        col: col
  }, accumulated_list_of_tiles_so_far) do

    new_tile = %{ row: row, col: col, character: this_letter }
    new_list_of_tiles = accumulated_list_of_tiles_so_far ++ [new_tile]

    {next_letter, next_remaining_text} = remaining_text |> String.split_at(1)

    recursively_generate_tiles(%{
          this_letter: next_letter,
          remaining_text: next_remaining_text,
          row: row,
          col: col+1
      },
      new_list_of_tiles
    )
  end



  def render_tiles(graph, _frame, [] = _list_of_tiles, _opts) do
    graph
  end

  def render_tiles(graph, frame, [tile|rest_of_the_tiles], opts) do

    %{block_width: block_width, block_height: block_height} = opts

    block_dimensions = {block_width, block_height}

    # maybe we make each box, just slightly bigger than a character...
    box_buffer = 1

    block_position_x = frame.coordinates.x + tile.col*block_width + @left_margin
    block_position_y = frame.coordinates.y + tile.row*block_height

    text_bottom_buffer = 2*box_buffer

    block_position = {block_position_x, block_position_y}
    text_position  = {block_position_x, block_position_y + (block_height-text_bottom_buffer)} # need to add the `block_height` offset, because Scenic draws text from the bottom for some reason...

    if opts.mode == :insert do
      if is_cursor_tile?(tile, opts) and opts.cursor_blink? do

        background_color = GUI.Colors.background()
        text_color = GUI.Colors.foreground()

        blinking_line_cursor_dimensions = {2, block_height}

        new_graph =
          graph
          |> Scenic.Primitives.rect(block_dimensions,
                        translate: block_position,
                             fill: background_color)
          # blinking cursor
          |> Scenic.Primitives.rect(blinking_line_cursor_dimensions,
                        translate: block_position,
                             fill: text_color)
          |> Scenic.Primitives.text(tile.character,
                        translate: text_position,
                             fill: text_color)

        render_tiles(new_graph, frame, rest_of_the_tiles, opts)

      else

        background_color = GUI.Colors.background()
        text_color = GUI.Colors.foreground()

        new_graph =
          graph
          |> Scenic.Primitives.rect(block_dimensions,
                      translate: block_position,
                          fill: background_color)
          |> Scenic.Primitives.text(tile.character,
                      translate: text_position,
                          fill: text_color)

        render_tiles(new_graph, frame, rest_of_the_tiles, opts)

      end
    else
      %{background_color: background_color, text_color: text_color} =
        tile_colors(tile, opts)

      new_graph =
        graph
        |> Scenic.Primitives.rect(block_dimensions,
                    translate: block_position,
                        fill: background_color)
        |> Scenic.Primitives.text(tile.character,
                    translate: text_position,
                        fill: text_color)

      render_tiles(new_graph, frame, rest_of_the_tiles, opts)
    end
  end


  # def tile_colors(tile, %{mode: :insert} = opts) do
  #   if is_cursor_tile?(tile, opts) and opts.cursor_blink? do
  #     %{
  #       background_color: GUI.Colors.foreground(),
  #       text_color: GUI.Colors.background()
  #     }
  #   else
  #     %{
  #       background_color: GUI.Colors.background(),
  #       text_color: GUI.Colors.foreground()
  #     }
  #   end
  # end

  def tile_colors(tile, opts) do
    if is_cursor_tile?(tile, opts) and opts.cursor_blink? do
      %{
        background_color: GUI.Colors.foreground(),
        text_color: GUI.Colors.background()
      }
    else
      %{
        background_color: GUI.Colors.background(),
        text_color: GUI.Colors.foreground()
      }
    end
  end

  def is_cursor_tile?(%{row: tile_row, col: tile_col}, %{cursor: %{row: cursor_row, col: cursor_col}})
  when tile_row == cursor_row and tile_col == cursor_col do
    true
  end
  def is_cursor_tile?(_tile, _cursor), do: false

end










  # def render_data_blocks(graph, frame, %{row: _r, column: col, letter: @newline_character}, rest) do
  #   {new_letter, new_rest} = rest |> String.split_at(1)
  #   #NOTE: resetting at row 1 cause I'm experimenting with that right now...
  #   render_data_blocks(graph, frame, %{row: 1, column: col+1, letter: new_letter}, new_rest)
  # end
  # def render_data_blocks(graph, _frame, %{row: _r, column: _c, letter: _l}, "" = _rest) do
  #   # base case - we've finished rendering blocks now
  #   graph
  # end
  # def render_data_blocks(graph, frame, %{row: row, column: col, letter: letter}, rest) do

  #   # maybe we make each box, just slightly bigger than a character...
  #   box_buffer = 1

  #   left_margin = 7

  #   block_width  = box_buffer + GUI.FontHelpers.monospace_font_width(:ibm_plex_mono, 24) #TODO need to get the variable amount, not a card-coded value here somehow...
  #   block_height = box_buffer + GUI.FontHelpers.monospace_font_height(:ibm_plex_mono, 24)

  #   block_position_x = frame.coordinates.x + row*block_width + left_margin
  #   block_position_y = frame.coordinates.y + col*block_height

  #   text_bottom_buffer = 2*box_buffer

  #   block_position = {block_position_x, block_position_y}
  #   text_position  = {block_position_x, block_position_y + (block_height-text_bottom_buffer)} # need to add the `block_height` offset, because Scenic draws text from the bottom for some reason...

  #   background_color =
  #     if row == 12 and col == 0 do
  #       GUI.Colors.background()
  #     else
  #       GUI.Colors.foreground()
  #     end
  #   text_color =
  #     if row == 12 and col == 0 do
  #       GUI.Colors.foreground()
  #     else
  #       GUI.Colors.background()
  #     end

  #   new_graph =
  #     graph
  #     |> Scenic.Primitives.rect({block_width, block_height}, translate: block_position, fill: background_color)
  #     |> Scenic.Primitives.text(letter, translate: text_position, fill: text_color)

  #   {new_letter, new_rest} = rest |> String.split_at(1)

  #   #TODO lol diamond is cool!! row: row+1, column: col+1
  #   render_data_blocks(new_graph, frame, %{row: row+1, column: col, letter: new_letter}, new_rest)
  # end
