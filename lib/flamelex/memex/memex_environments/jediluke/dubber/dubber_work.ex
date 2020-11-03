defmodule Flamelex.Memex.Env.JediLuke.DubberWork do
  #TODO have Episteme modules implement a behaviour/protocol, forcing them
  #to present a description/references/etc

  @doc """
  This is my list of
  """
  def todo_list do
       razum()
    ++ maynard()
    ++ production_issues()
    ++ special_projects()
    ++ education_and_training()
  end

  def razum do
    [
      "fix up speaker diarization writeup"
    ]
  end

  def maynard do
    [
      "get tix pushed through QA"
    ]
  end

  def production_issues do
    maynard_honeybadgers()
    ++
    [
      "honeybadgers in may"
    ]
  end

  def maynard_honeybadgers do
    [
      "DB connection thing, being solved by config",
      ""
    ]
  end

  def special_projects do
    [
      "hosting our own HexPM",
      "running our own CLI tools in mix",
      "record Zoom",
      "record that instant meeting app",
      "ingest MS teams & use that for my account"
    ]
  end

  def education_and_training do
    brownbags_i_want_to_give()
  end

  def brownbags_i_want_to_give do
    ai_demo_including_anomylie_detection()
    ++ [
      "redo Erlang demo of hot deploy",
      "case study in supervision trees: error handling when using a cache for token credentials"
    ]
  end

  def ai_demo_including_anomylie_detection do
    [
      "recap so far",
      "topic modelling",
      "anomylie detection",
      "sagemaker",
      "s3 permissions"
    ]
  end
end
