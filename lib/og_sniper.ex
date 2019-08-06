defmodule OgSniper do
  alias OgSniper.Utils

  def start do

    {:ok, time_to_snipe} = Utils.username_to_uuid("pwq") 
                           |> Utils.get_change_timestamp
                           |> Utils.add_37_days
    
    OgSniper.Ninja.start_link(%{
      desired_name: "pwq", 
      snipe_at_timestamp: time_to_snipe, 
      minecraft_email: "ddadad@rmailcloud.com", 
      minecraft_password: "Krom11!!",
      giftcode: "A1A1A-B2B2B-C3C3C-D4D4D-E5E5E"})
    :ok
  end
end
