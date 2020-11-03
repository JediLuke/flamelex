defmodule Flamelex.Memex.Env.JediLuke.Dub.Environments do

  def list do
    [
      :dev,
      :uat,
      :stg,
      :sbox,
      :na,
      :emea,
      :apac
    ]
  end


  def connecting_to_dev do
    "k8 instructions I guess"
  end

  def deploying_to_dev do
    "https://jenkins.tools.nonprod.dubber.io/blue/organizations/jenkins/apps%2Fconnectors%2FRingCentral%2FDeploy/activity"
  end

  def uat_portal_url do
    "puddles.dubber.net/login"
    # "https://in-prod.dubber.net/login" # WTF is in-prod then??
  end
end
