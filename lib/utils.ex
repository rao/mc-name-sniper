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

    def send_captcha do
        %HTTPoison.Response{body: body} = HTTPoison.get!("https://2captcha.com/in.php?key=bbe7d8b5a2b151828c8268ae93334bae&method=userrecaptcha&googlekey=6LfbsiMUAAAAAOu1nGK8InBaFrIk17dcbI0sqvzj&invisible=1&pageurl=https://my.minecraft.net/en-us/redeem/minecraft/#redeem")
        
        body
        |> String.replace_leading(body, "OK|", "")
        |> IO.puts("captchaToken")
    end

    def attempt_minecraft_auth(minecraft_email, minecraft_password, captchaToken) do
        %HTTPoison.Response{body: body} = HTTPoison.post!("https://authserver.mojang.com/authenticate", Poison.encode(%{
            "captcha" => captchaToken,
            "captchaSupported" => "InvisibleReCAPTCHA",
            "password" => password,
            "username" => email,
            "requestUser" => true
            }), [{"Content-Type", "application/json"}])
        
        body
        |> Poison.decode!
        |> Map.get("accessToken")
    end

    def snipe_process(accessToken) do
        HTTPoison.put!(
            "https://api.mojang.com/user/profile/agent/minecraft/name/name", 
            nil, 
            [{"Authorization", "Bearer #{accessToken}"},
            {"User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/75.0.3770.142 Safari/537.36"},
            {"Origin", "https://my.minecraft.net"},
            {"Referer", "https://my.minecraft.net/en-us/redeem/minecraft/"},
            {"Accept", "*/*"}]
        )

        HTTPoison.post!("https://api.mojang.com/token/redeem", Poison.encode(%{
            "code" => "A1A1A-B2B2B-C3C3C-D4D4D-E5E5E",
            "languageCode" => "en-us",
            "productType:" => "GAME"
            }),
        [{"Authorization", "Bearer #{accessToken}"},
        {"Accept", "application/json, text/javascript, */*; q=0.01"},
        {"Content-Type", "application/json"},
        {"User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/75.0.3770.142 Safari/537.36"}]
        )
    end
    
end
