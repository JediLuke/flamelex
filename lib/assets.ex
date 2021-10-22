defmodule Flamelex.Assets do
  use Scenic.Assets.Static,
    otp_app: :flamelex,
    alias: [
      ibm_plex_mono: "fonts/IBMPlexMono-Regular.ttf"
    ]
  end