defmodule OgSniper do
  alias OgSniper.Utils

  def start(_, _) do

    Utils.username_to_uuid("Evlerr") 
    |> Utils.get_change_timestamp
    |> IO.puts

    :ok
  end
end
