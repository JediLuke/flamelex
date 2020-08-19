defmodule GUI do

  # def register_new_buffer(type: :text, content: content, action: 'OPEN_FULL_SCREEN'), do: GUI.Scene.Root.action({'NEW_FRAME', [type: :text, content: content]})
  # def register_new_buffer(args), do: GUI.Controller.register_new_buffer(args)

  #TODO use a struct here
  # def show_fullscreen(buffer), do: GUI.Controller.show_fullscreen(buffer)
  # def show_fullscreen(buffer), do: GUI.Scene.Root.action({'NEW_FRAME', [type: :text, content: buffer.content]}) #TODO this action should be more like, SHOW_BUFFER_FULL_SCREEN

  def activate_command_buffer do
    GUI.Scene.Root.action('ACTIVATE_COMMAND_BUFFER')
  end
end
