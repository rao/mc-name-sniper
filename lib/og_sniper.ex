defmodule OgSniper do
  alias OgSniper.Utils

  def start do
    {:ok, time_to_snipe} = Utils.username_to_uuid("deathdead14") 
                           |> Utils.get_change_timestamp
                           |> Utils.add_37_days
                           
    OgSniper.Ninja.start_link(%{
      desired_name: "deathdead14", 
      snipe_at_timestamp: time_to_snipe, 
      minecraft_email: "kromislit@gmail.com", 
      minecraft_password: "Krom11!!",
      giftcode: "123 123 1234"})
    :ok
  end
end
