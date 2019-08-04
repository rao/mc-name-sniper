defmodule OgSniper do
  alias OgSniper.Utils

  def start do

    {:ok, time_to_snipe} = Utils.username_to_uuid("Program") 
                           |> Utils.get_change_timestamp
                           |> Utils.add_37_days
    
    OgSniper.Ninja.start_link(%{
      name_to_snipe: "Program", 
      snipe_at_timestamp: time_to_snipe, 
      mojang_email: "rramin125@gmail.com", 
      mojang_password: "gay", 
      minecraft_email: "testing@gmail.com", 
      minecraft_password: "test123",
      giftcode: "A1A1A-B2B2B-C3C3C-D4D4D-E5E5E"})

    :ok
  end
end
