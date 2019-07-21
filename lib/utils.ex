defmodule OgSniper.Utils do

    def username_to_uuid (desired_name) do
        # In line 5, it's getting that API in default format, then %HTTPoison.Response takes the body of what you want
        %HTTPoison.Response{body: body} = HTTPoison.get!("https://api.mojang.com/users/profiles/minecraft/" <> desired_name)

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

    end
end 