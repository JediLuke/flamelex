defmodule Flamelex.Memex.Env.JediLuke.MaryGraceGloria do
  alias Flamelex.Memex.Env.JediLuke

  def tasks do
    education_and_training()
    ++ advertising_my_programming_course()
    ++ helping_develop_my_programming_course()
    ++ helping_build_vostok()
    ++ JediLuke.Projects.hot_water_heater_monitor(:task_list)
  end

  def education_and_training do
    [
      "elixir beginner course",
      "phoenix dev & liveview"
    ]
  end

  def advertising_my_programming_course do
    [
      "get_credit_card_working"
    ]
  end

  def helping_build_vostok do
    [
      "sign IP agreement",
      "download code & get it running locally",
      "deploy a game to staging",
      "improve engineering station",
      "create game-design doc"
    ]
  end

  def helping_develop_my_programming_course do
    ["need to create programmin"]
  end

  def cost do
    {215, :dollars, :per_week}
  end
end
