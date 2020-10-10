defmodule Flamelex.Memex.Env.JediLuke.Projects do
  @moduledoc """
  My TODOs.
  """

  def list do
    merlixr()
    ++ flamelex()
    ++ neural_net_pinball()
    ++ shed_shop_robot_arm_workbench()
    ++ shed_shop_micro_manipulator()
    ++ hot_water_heater_monitor()
    ++ my_writing()
  end

  def my_writing do
    []
    # [
    #   %{"de_gauntlett_de_genevieve / quantum-coherent phase-lock": %{
    #     "get art cover done",
    #     "look into publishing",
    #     "start marketing the book",
    #     %{research:
    #       "McKenna"}}}

    #   ,

    # ]

    # ideas
    # spaceship which inverts time

  end



  def shed_shop_robot_arm_workbench() do
    [
      "weld up basi frame for robot arm workbench"
    ]
  end

  def shed_shop_micro_manipulator() do
    [
      "take cotton & turn it into microfibre using micro-manipulator version of workbench arms"
    ]
  end

  def hot_water_heater_monitor do
    [
      "find out what type of plug that hot water system uses",
      "find way of measuring current",
      "find way of connecting to WiFi",
      "find way of connecting to LTE/5g/NB-IoT/LoRa",
      "write script on RaspPi to pish CPU temperature to endpoint",
      "write server to handle endpoint"
    ]
  end

  def merlixr, do: [
    "create NN base library",
    "create visualization lib (either scnic or liveview)"
  ]

  def flamelex, do: "see: `README.md`"

  def neural_net_pinball, do: [
    "look on craigslist ",
    "create visualization lib (either scnic or liveview)"
  ]

  def hot_water_heater_monitor(:task_list) do
    [
      "get script for Raspberry Pi to push temp to internet",
      "develop Phoenix LiveView webserver to show it"
    ]
  end

  def programming_course do
    introduction_to_programming(:description)
  end

  def introduction_to_programming(:description) do
    [
      "12 weeks",
      "costs $400",
      "class size of ~12",
      "7 modules"
    ]
  end

  def introduction_to_programming(:description_2) do
    "7 module course that teaches beginners the fundamentals of computer programming"
  end

  def introduction_to_programming(:tasks) do
    [
      "get advertising working on FB",
      "incentivize Grace (7 - 11 - 15) students bracket"
    ]
  end
end
