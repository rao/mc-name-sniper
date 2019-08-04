defmodule OgSniper.Utils do

    def username_to_uuid(desired_name) do
        days_ago = :os.system_time(:second) - 3196800
        
        # In line 5, it's getting that API in default format, then %HTTPoison.Response takes the body of what you want
        %HTTPoison.Response{body: body} = HTTPoison.get!("https://api.mojang.com/users/profiles/minecraft/" <> desired_name <> "?at=" <> Integer.to_string(days_ago))

        body
        |> Poison.decode! # converts string of JSON to an elixir map
        |> Map.get("id") # fetching the thing you want

    end

    def get_change_timestamp(uuid) do
        %HTTPoison.Response{body: body} = HTTPoison.get!("https://api.mojang.com/user/profiles/" <> uuid <> "/names")

        body
        |> Poison.decode! 
        |> List.last # get the last of the list lol
        |> Map.get("changedToAt")
        |> Kernel./(1000)
    end

    def add_37_days(changedToAt) do

        time_now = :os.system_time(:second)

        moment_of_change = changedToAt + 3196800

        cond do
            moment_of_change > time_now -> 
                {:ok, moment_of_change}
            moment_of_change < time_now ->
                {:error}
        end
    end
end
