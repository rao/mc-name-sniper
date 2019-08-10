defmodule OgSniper do
  alias OgSniper.Utils
  use Application

  def start do
    import Supervisor.Spec, warn: false
    children = [
      supervisor(OgSniper.MojangLatency, [])
    ]
    
    opts = [strategy: :one_for_one, name: OgSniper.Supervisor]
    Supervisor.start_link(children, opts)

    {:ok, time_to_snipe} = Utils.username_to_uuid("Slums") 
                           |> Utils.get_change_timestamp
                           |> Utils.add_37_days
                           
    OgSniper.Ninja.start_link(%{
      desired_name: "Slums", 
      snipe_at_timestamp: time_to_snipe, 
      minecraft_email: "kromislit@gmail.com", 
      minecraft_password: "Krom11!!",
      giftcode: "123 123 1234"})
    :ok
  end
end
