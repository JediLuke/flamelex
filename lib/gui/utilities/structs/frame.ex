defmodule GUI.Structs.Frame do
  @moduledoc """
  Struct which holds relevant data for rendering a buffer frame status bar.

  Might need a better name for this, but I basically just mean this is what
  we use to pass in the data when rendering a BufferFrame.
  """
  require Logger
  # alias __MODULE__.Token

  # @valid_buffer_types [:list] # all the types of buffer that you can have

  defstruct [
    width: 0,
    height: 0
  ]

  # defmodule __MODULE__.Token do
  #   defstruct [
  #     halted?: false,
  #     errors: [],
  #     data: %{}
  #   ]
  # end


  # def initialize(%{buffer_type: _b, name: _n, width: _w, height: _h} = data) do
  #   struct(__MODULE__, data) # return the struct
  #   # %Token{data: data}
  #   # case data |> is_valid? do
  #   #   %{is_valid?: true} = data ->
  #   #     struct(__MODULE__, data) # return the struct
  #   #   _else ->
  #   #     error_msg = "Invalid data when initializing #{__MODULE__}."
  #   #     Logger.error error_msg <> " data: #{inspect data}"
  #   #     raise error_msg
  #   # end
  # end


  ## private functions
  ## -------------------------------------------------------------------


  # defp validate_options(%Token{data: data} = token) do
  #   errors = [
  #     # if(Enum.empty?(filenames), do: "No images found."),
  #     # if(!Enum.member?(~w[jpg png], format), do: "Unrecognized format: #{format}")
  #   ]

  #   %Token{token | errors: errors, halted?: Enum.any?(errors)}
  # end


  # defp is_valid?(data) do
  #   data |> create_token()
  #   |> validate_buffer_type()
  #   |> validate_name()
  # end

  # defp create_token(data) do
  #   %{
  #     data: data,
  #     results: []
  #   }
  # end

  # defp validate_buffer_type({_is_valid?, %{buffer_type: t} = data}) when t in @valid_buffer_types, do: {true, data}
  # defp validate_buffer_type({_is_valid?, data}), do: {data, false}

  # defp validate_name(%{name: ""} = data) do

  # end
  # defp validate_name(%{name: n}) when is_binary(n), do: true
  # defp validate_name(_else), do: false

end
